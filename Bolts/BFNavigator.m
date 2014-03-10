/*
 *  Copyright (c) 2014, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import <UIKit/UIKit.h>

#import "BFNavigator.h"
#import "BFTaskCompletionSource.h"
#import "BFAppLinkTarget.h"
#import "BoltsVersion.h"

// Defines JavaScript to extract app link tags from HTML content
#define AL_TAG_EXTRACTION_JAVASCRIPT @"" \
"(function() {" \
"  var metaTags = document.getElementsByTagName('meta');" \
"  var results = [];" \
"  for (var i = 0; i < metaTags.length; i++) {" \
"    var property = metaTags[i].getAttribute('property');" \
"    if (property && property.substring(0, 'al:'.length) === 'al:') {" \
"      var tag = { \"property\": metaTags[i].getAttribute('property') };" \
"      if (metaTags[i].hasAttribute('content')) {" \
"        tag['content'] = metaTags[i].getAttribute('content');" \
"      }" \
"      results.push(tag);" \
"    }" \
"  }" \
"  return JSON.stringify(results);" \
"})()"

#define AL_IOS_URL_KEY @"url"
#define AL_IOS_APP_STORE_ID_KEY @"app_store_id"
#define AL_IOS_APP_NAME_KEY @"app_name"
#define AL_DICTIONARY_VALUE_KEY @"_value"
#define AL_PREFER_HEADER @"Prefer-Html-Meta-Tags"
#define AL_META_TAG_PREFIX @"al"


@interface BFWebViewListener : NSObject <UIWebViewDelegate>

@property (nonatomic, copy) void (^didFinishLoad)(UIWebView *webView);
@property (nonatomic, copy) void (^didFailLoadWithError)(UIWebView *webView, NSError *error);

@end

@implementation BFWebViewListener

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (self.didFinishLoad) {
        self.didFinishLoad(webView);
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (self.didFailLoadWithError) {
        self.didFailLoadWithError(webView, error);
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

@end

@interface BFNavigator ()

@end

@implementation BFNavigator

/*
 Builds up a data structure filled with the app link data from the meta tags on a page.
 The structure of this object is a dictionary where each key holds an array of app link
 data dictionaries.  Values are stored in a key called "_value".
 */
+ (NSDictionary *)parseALData:(NSArray *)dataArray {
    NSMutableDictionary *al = [NSMutableDictionary dictionary];
    for (NSDictionary *tag in dataArray) {
        NSString *name = tag[@"property"];
        if (name == (id)[NSNull null]) continue;
        NSArray *nameComponents = [name componentsSeparatedByString:@":"];
        if (![nameComponents[0] isEqualToString:AL_META_TAG_PREFIX]) {
            continue;
        }
        NSMutableDictionary *root = al;
        for (int i = 1; i < nameComponents.count; i++) {
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
            root[AL_DICTIONARY_VALUE_KEY] = tag[@"content"];
        }
    }
    return al;
}

+ (NSDictionary *)getALDataFromLoadedPage:(UIWebView *)webView {
    // Run some JavaScript in the webview to fetch the meta tags.
    NSString *jsonString = [webView stringByEvaluatingJavaScriptFromString:AL_TAG_EXTRACTION_JAVASCRIPT];
    NSError *error = nil;
    NSArray *arr = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
                                                   options:0
                                                     error:&error];
    return [self parseALData:arr];
}

/*
 Converts app link data into a BFAppLink containing the targets relevant for this platform.
 */
+ (BFAppLink *)appLinkFromALData:(NSDictionary *)appLinkDict destination:(NSURL *)destination {
    NSMutableArray *linkTargets = [NSMutableArray array];
    
    NSArray *platformData = nil;
    switch (UI_USER_INTERFACE_IDIOM()) {
        case UIUserInterfaceIdiomPad:
            platformData = @[appLinkDict[@"ipad"] ?: @{}, appLinkDict[@"ios"] ?: @{}];
            break;
        case UIUserInterfaceIdiomPhone:
            platformData = @[appLinkDict[@"iphone"] ?: @{}, appLinkDict[@"ios"] ?: @{}];
            break;
        default:
            // Future-proofing. Other User Interface idioms should only hit ios.
            platformData = @[appLinkDict[@"ios"] ?: @{}];
            break;
    }
    
    for (NSArray *platformObjects in platformData) {
        for (NSDictionary *platformDict in platformObjects) {
            // The schema requires a single url/app store id/app name,
            // but we could find multiple of them. We'll make a best effort
            // to interpret this data.
            NSArray *urls = platformDict[AL_IOS_URL_KEY];
            NSArray *appStoreIds = platformDict[AL_IOS_APP_STORE_ID_KEY];
            NSArray *appNames = platformDict[AL_IOS_APP_NAME_KEY];
            
            NSUInteger maxCount = MAX(urls.count, MAX(appStoreIds.count, appNames.count));
            
            for (NSUInteger i = 0; i < maxCount; i++) {
                NSString *urlString = urls[i][AL_DICTIONARY_VALUE_KEY];
                NSURL *url = urlString ? [NSURL URLWithString:urlString] : nil;
                NSString *appStoreId = appStoreIds[i][AL_DICTIONARY_VALUE_KEY];
                NSString *appName = appNames[i][AL_DICTIONARY_VALUE_KEY];
                BFAppLinkTarget *target = [BFAppLinkTarget appLinkTargetWithURL:url
                                                                     appStoreId:appStoreId
                                                                        appName:appName];
                [linkTargets addObject:target];
            }
        }
    }
    
    NSString *webUrlString = appLinkDict[@"web"][0][@"url"][0][AL_DICTIONARY_VALUE_KEY];
    NSURL *webUrl;
    if (webUrlString) {
        if ([@[@"none", @""] containsObject:webUrlString]) {
            webUrl = nil;
        } else {
            webUrl = [NSURL URLWithString:webUrlString];
        }
    } else {
        webUrl = destination;
    }

    return [BFAppLink appLinkWithSourceURL:destination
                                   targets:linkTargets
                                    webURL:webUrl];
}

+ (BFTask *)resolveAppLink:(NSURL *)destination {
    // Yep, it's a dirty hack to use a WebView to parse HTML for us, but it's safe and simple for now.
    BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWebView *webView = [[UIWebView alloc] init];
        BFWebViewListener *listener = [[BFWebViewListener alloc] init];
        __block BFWebViewListener *retainedListener = listener;
        listener.didFinishLoad = ^(UIWebView *view) {
            if (retainedListener) {
                NSDictionary *ogData = [self getALDataFromLoadedPage:view];
                [view removeFromSuperview];
                view.delegate = nil;
                retainedListener = nil;
                [tcs setResult:[self appLinkFromALData:ogData destination:destination]];
            }
        };
        listener.didFailLoadWithError = ^(UIWebView* view, NSError *error) {
            if (retainedListener) {
                [view removeFromSuperview];
                view.delegate = nil;
                retainedListener = nil;
                [tcs setError:error];
            }
        };
        webView.delegate = listener;
        webView.hidden = YES;
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:destination];
        [request setValue:AL_META_TAG_PREFIX forHTTPHeaderField:AL_PREFER_HEADER];
        [webView loadRequest:request];
        UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
        [window addSubview:webView];
    });
    
    return tcs.task;
}

+ (BFTask *)navigateToURL:(NSURL *)destination {
    return [self navigateToURL:destination headers:nil];
}

+ (BFTask *)navigateToURL:(NSURL *)destination headers:(NSDictionary *)headers {
    return [[self resolveAppLink:destination] continueWithSuccessBlock:^id(BFTask *task) {
        BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = nil;
            BFNavigationType result = [self navigateToAppLink:task.result headers:headers error:&error];
            if (error) {
                [tcs setError:error];
            } else {
                [tcs setResult:@(result)];
            }
        });
        return tcs.task;
    }];
}

+ (BFNavigationType)navigateToAppLink:(BFAppLink *)link error:(NSError **)error {
    return [self navigateToAppLink:link headers:nil error:error];
}

+ (NSString *)stringByEscapingQueryString:(NSString *)string {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (CFStringRef)string,
                                                                                 NULL,
                                                                                 (CFStringRef)@":/?#[]@!$&'()*+,;=",
                                                                                 kCFStringEncodingUTF8));
}

+ (BFNavigationType)navigateToAppLink:(BFAppLink *)link headers:(NSDictionary *)headers error:(NSError **)error {
    // Find the first eligible/launchable target in the BFAppLink.
    BFAppLinkTarget *eligibleTarget = nil;
    for (BFAppLinkTarget *target in link.targets) {
        if ([[UIApplication sharedApplication] canOpenURL:target.url]) {
            eligibleTarget = target;
            break;
        }
    }
    
    if (eligibleTarget) {
        NSURL *targetUrl = eligibleTarget.url;
        NSMutableDictionary *augmentedHeaders = [NSMutableDictionary dictionaryWithDictionary:headers ?: @{}];
        
        // Add good browser headers
        augmentedHeaders[BFAPPLINK_USER_AGENT_HEADER_NAME] = [NSString stringWithFormat:@"Bolts iOS %@", BOLTS_VERSION];
        augmentedHeaders[BFAPPLINK_TARGET_HEADER_NAME] = [link.sourceURL absoluteString];
        
        // JSON-ify the applink data
        NSError *jsonError = nil;
        NSData *jsonBlob = [NSJSONSerialization dataWithJSONObject:augmentedHeaders options:0 error:&jsonError];
        if (!jsonError) {
            NSString *jsonString = [[NSString alloc] initWithData:jsonBlob encoding:NSUTF8StringEncoding];
            NSString *encoded = [self stringByEscapingQueryString:jsonString];
            
            NSString *endUrlString = [NSString stringWithFormat:@"%@%@%@=%@",
                                      [targetUrl absoluteString],
                                      targetUrl.query ? @"&" : @"?",
                                      BFAPPLINK_DATA_PARAMETER_NAME,
                                      encoded];
            // Attempt to navigate
            if ([[UIApplication sharedApplication] openURL:[NSURL URLWithString:endUrlString]]) {
                return BFNavigationTypeApp;
            }
        } else {
            if (error) {
                *error = jsonError;
            }
            
            // If there was an error encoding the headers, fail hard.
            return BFNavigationTypeFailure;
        }
    }
    
    // Fall back to opening the url in the browser if available.
    if (link.webURL) {
        if ([[UIApplication sharedApplication] openURL:link.webURL]) {
            return BFNavigationTypeBrowser;
        }
    }
    
    // Otherwise, navigation fails.
    return BFNavigationTypeFailure;
}

@end
