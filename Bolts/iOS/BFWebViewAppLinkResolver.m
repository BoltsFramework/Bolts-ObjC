/*
 *  Copyright (c) 2014, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import <WebKit/WebKit.h>

#import "BFWebViewAppLinkResolver.h"
#import "BFAppLink.h"
#import "BFAppLinkTarget.h"
#import "BFTask.h"
#import "BFTaskCompletionSource.h"
#import "BFExecutor.h"

// Defines JavaScript to extract app link tags from HTML content
static NSString *const BFWebViewAppLinkResolverTagExtractionJavaScript = @""
"(function() {"
"  var metaTags = document.getElementsByTagName('meta');"
"  var results = [];"
"  for (var i = 0; i < metaTags.length; i++) {"
"    var property = metaTags[i].getAttribute('property');"
"    if (property && property.substring(0, 'al:'.length) === 'al:') {"
"      var tag = { \"property\": metaTags[i].getAttribute('property') };"
"      if (metaTags[i].hasAttribute('content')) {"
"        tag['content'] = metaTags[i].getAttribute('content');"
"      }"
"      results.push(tag);"
"    }"
"  }"
"  return JSON.stringify(results);"
"})()";
static NSString *const BFWebViewAppLinkResolverIOSURLKey = @"url";
static NSString *const BFWebViewAppLinkResolverIOSAppStoreIdKey = @"app_store_id";
static NSString *const BFWebViewAppLinkResolverIOSAppNameKey = @"app_name";
static NSString *const BFWebViewAppLinkResolverDictionaryValueKey = @"_value";
static NSString *const BFWebViewAppLinkResolverPreferHeader = @"Prefer-Html-Meta-Tags";
static NSString *const BFWebViewAppLinkResolverMetaTagPrefix = @"al";
static NSString *const BFWebViewAppLinkResolverWebKey = @"web";
static NSString *const BFWebViewAppLinkResolverIOSKey = @"ios";
static NSString *const BFWebViewAppLinkResolverIPhoneKey = @"iphone";
static NSString *const BFWebViewAppLinkResolverIPadKey = @"ipad";
static NSString *const BFWebViewAppLinkResolverWebURLKey = @"url";
static NSString *const BFWebViewAppLinkResolverShouldFallbackKey = @"should_fallback";

@interface BFWebViewAppLinkResolverWebViewDelegate : NSObject <WKNavigationDelegate>

@property (nonatomic, copy) void (^didFinishLoad)(WKWebView *webView);
@property (nonatomic, copy) void (^didFailLoadWithError)(WKWebView *webView, NSError *error);
@property (nonatomic, assign) BOOL hasLoaded;

@end

@implementation BFWebViewAppLinkResolverWebViewDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    if (self.didFinishLoad) {
        self.didFinishLoad(webView);
    }
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    if (self.didFailLoadWithError) {
        self.didFailLoadWithError(webView, error);
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if (self.hasLoaded) {
        // Consider loading a second resource to be "success", since it indicates an inner frame
        // or redirect is happening. We can run the tag extraction script at this point.
        self.didFinishLoad(webView);
    }
    self.hasLoaded = YES;
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

@end

@implementation BFWebViewAppLinkResolver

+ (instancetype)sharedInstance {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (BFTask *)followRedirects:(NSURL *)url {
    // This task will be resolved with either the redirect NSURL
    // or a dictionary with the response data to be returned.
    BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:BFWebViewAppLinkResolverMetaTagPrefix forHTTPHeaderField:BFWebViewAppLinkResolverPreferHeader];

    void (^completion)(NSURLResponse *response, NSData *data, NSError *error) = ^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            [tcs setError:error];
            return;
        }

        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

            // NSURLConnection usually follows redirects automatically, but the
            // documentation is unclear what the default is. This helps it along.
            if (httpResponse.statusCode >= 300 && httpResponse.statusCode < 400) {
                NSString *redirectString = httpResponse.allHeaderFields[@"Location"];
                NSURL *redirectURL = [NSURL URLWithString:redirectString];
                [tcs setResult:redirectURL];
                return;
            }
        }

        [tcs setResult:@{ @"response" : response, @"data" : data }];
    };

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_7_0 || __MAC_OS_X_VERSION_MIN_REQUIRED >= __MAC_10_9
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        completion(response, data, error);
    }] resume];
#else
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:completion];
#endif

    return [tcs.task continueWithSuccessBlock:^id(BFTask *task) {
        // If we redirected, just keep recursing.
        if ([task.result isKindOfClass:[NSURL class]]) {
            return [self followRedirects:task.result];
        }
        return task;
    }];
}

- (BFTask *)appLinkFromURLInBackground:(NSURL *)url NS_EXTENSION_UNAVAILABLE_IOS("") {
    return [[self followRedirects:url] continueWithExecutor:[BFExecutor mainThreadExecutor]
                                           withSuccessBlock:^id(BFTask *task) {
                                               NSData *responseData = task.result[@"data"];
                                               NSHTTPURLResponse *response = task.result[@"response"];
                                               BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];

                                               WKWebView *webView = [[WKWebView alloc] init];
                                               BFWebViewAppLinkResolverWebViewDelegate *listener = [[BFWebViewAppLinkResolverWebViewDelegate alloc] init];
                                               __block BFWebViewAppLinkResolverWebViewDelegate *retainedListener = listener;
                                               listener.didFinishLoad = ^(WKWebView *view) {
                                                   if (retainedListener) {
                                                       [self getALDataFromLoadedPage:view completion:^(NSDictionary *result, NSError *error) {
                                                           [view removeFromSuperview];
                                                           view.navigationDelegate = nil;
                                                           retainedListener = nil;
                                                           [tcs setResult:[self appLinkFromALData:result destination:url]];
                                                       }];
                                                   }
                                               };
                                               listener.didFailLoadWithError = ^(WKWebView* view, NSError *error) {
                                                   if (retainedListener) {
                                                       [view removeFromSuperview];
                                                       view.navigationDelegate = nil;
                                                       retainedListener = nil;
                                                       [tcs setError:error];
                                                   }
                                               };
                                               webView.navigationDelegate = listener;
                                               webView.configuration.preferences.javaScriptEnabled = true;
                                               webView.hidden = YES;
                                               if (@available(iOS 9.0, *)) {
                                                [webView loadData:responseData
                                                         MIMEType:response.MIMEType
                                            characterEncodingName:response.textEncodingName
                                                          baseURL:response.URL];

                                                UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
                                                [window addSubview:webView];
                                               } else {
                                                    // Fallback on earlier versions
                                               }

                                               return tcs.task;
                                           }];
}

/*
 Builds up a data structure filled with the app link data from the meta tags on a page.
 The structure of this object is a dictionary where each key holds an array of app link
 data dictionaries.  Values are stored in a key called "_value".
 */
- (NSDictionary *)parseALData:(NSArray *)dataArray {
    NSMutableDictionary *al = [NSMutableDictionary dictionary];
    for (NSDictionary *tag in dataArray) {
        NSString *name = tag[@"property"];
        if (![name isKindOfClass:[NSString class]]) {
            continue;
        }
        NSArray *nameComponents = [name componentsSeparatedByString:@":"];
        if (![nameComponents[0] isEqualToString:BFWebViewAppLinkResolverMetaTagPrefix]) {
            continue;
        }
        NSMutableDictionary *root = al;
        for (NSUInteger i = 1; i < nameComponents.count; i++) {
            NSMutableArray *children = root[nameComponents[i]];
            if (!children) {
                children = [NSMutableArray array];
                root[nameComponents[i]] = children;
            }
            NSMutableDictionary *child = children.lastObject;
            if (!child || i == nameComponents.count - 1) {
                child = [NSMutableDictionary dictionary];
                [children addObject:child];
            }
            root = child;
        }
        if (tag[@"content"]) {
            root[BFWebViewAppLinkResolverDictionaryValueKey] = tag[@"content"];
        }
    }
    return al;
}

- (void)getALDataFromLoadedPage:(WKWebView *)webView completion:(void (^ _Nullable)(NSDictionary * _Nullable, NSError * _Nullable error))completionHandler {
    [webView evaluateJavaScript:BFWebViewAppLinkResolverTagExtractionJavaScript completionHandler:^(id result, NSError * error) {
        if (error == nil) {
            NSString *jsonString = result;
            NSError *parseError = nil;
            NSArray *arr = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
                                                           options:0
                                                             error:&parseError];
            completionHandler([self parseALData:arr], parseError);
        } else {
            completionHandler(nil, error);
        }
    }];
}

/*
 Converts app link data into a BFAppLink containing the targets relevant for this platform.
 */
- (BFAppLink *)appLinkFromALData:(NSDictionary *)appLinkDict destination:(NSURL *)destination {
    NSMutableArray *linkTargets = [NSMutableArray array];

    NSArray *platformData = nil;

    const UIUserInterfaceIdiom idiom = UI_USER_INTERFACE_IDIOM();
    if (idiom == UIUserInterfaceIdiomPad) {
        platformData = @[ appLinkDict[BFWebViewAppLinkResolverIPadKey] ?: @{},
                          appLinkDict[BFWebViewAppLinkResolverIOSKey] ?: @{} ];
    } else if (idiom == UIUserInterfaceIdiomPhone) {
        platformData = @[ appLinkDict[BFWebViewAppLinkResolverIPhoneKey] ?: @{},
                          appLinkDict[BFWebViewAppLinkResolverIOSKey] ?: @{} ];
    } else {
        // Future-proofing. Other User Interface idioms should only hit ios.
        platformData = @[ appLinkDict[BFWebViewAppLinkResolverIOSKey] ?: @{} ];
    }

    for (NSArray *platformObjects in platformData) {
        for (NSDictionary *platformDict in platformObjects) {
            // The schema requires a single url/app store id/app name,
            // but we could find multiple of them. We'll make a best effort
            // to interpret this data.
            NSArray *urls = platformDict[BFWebViewAppLinkResolverIOSURLKey];
            NSArray *appStoreIds = platformDict[BFWebViewAppLinkResolverIOSAppStoreIdKey];
            NSArray *appNames = platformDict[BFWebViewAppLinkResolverIOSAppNameKey];

            NSUInteger maxCount = MAX(urls.count, MAX(appStoreIds.count, appNames.count));

            for (NSUInteger i = 0; i < maxCount; i++) {
                NSString *urlString = urls[i][BFWebViewAppLinkResolverDictionaryValueKey];
                NSURL *url = urlString ? [NSURL URLWithString:urlString] : nil;
                NSString *appStoreId = appStoreIds[i][BFWebViewAppLinkResolverDictionaryValueKey];
                NSString *appName = appNames[i][BFWebViewAppLinkResolverDictionaryValueKey];
                BFAppLinkTarget *target = [BFAppLinkTarget appLinkTargetWithURL:url
                                                                     appStoreId:appStoreId
                                                                        appName:appName];
                [linkTargets addObject:target];
            }
        }
    }

    NSDictionary *webDict = appLinkDict[BFWebViewAppLinkResolverWebKey][0];
    NSString *webUrlString = webDict[BFWebViewAppLinkResolverWebURLKey][0][BFWebViewAppLinkResolverDictionaryValueKey];
    NSString *shouldFallbackString = webDict[BFWebViewAppLinkResolverShouldFallbackKey][0][BFWebViewAppLinkResolverDictionaryValueKey];

    NSURL *webUrl = destination;

    if (shouldFallbackString &&
        [@[ @"no", @"false", @"0" ] containsObject:[shouldFallbackString lowercaseString]]) {
        webUrl = nil;
    }
    if (webUrl && webUrlString) {
        webUrl = [NSURL URLWithString:webUrlString];
    }

    return [BFAppLink appLinkWithSourceURL:destination
                                   targets:linkTargets
                                    webURL:webUrl];
}

@end
