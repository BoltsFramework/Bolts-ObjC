//
//  BFWebViewAppLinkResolver.m
//  Bolts
//
//  Created by David Poll on 3/10/14.
//  Copyright (c) 2014 Parse Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BFWebViewAppLinkResolver.h"
#import "BFAppLink.h"
#import "BFAppLinkTarget.h"
#import "BFTask.h"
#import "BFTaskCompletionSource.h"

// Defines JavaScript to extract app link tags from HTML content
#define BFWEBVIEWAPPLINKRESOLVER_TAG_EXTRACTION_JAVASCRIPT @"" \
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

#define BFWEBVIEWAPPLINKRESOLVER_IOS_URL_KEY @"url"
#define BFWEBVIEWAPPLINKRESOLVER_IOS_APP_STORE_ID_KEY @"app_store_id"
#define BFWEBVIEWAPPLINKRESOLVER_IOS_APP_NAME_KEY @"app_name"
#define BFWEBVIEWAPPLINKRESOLVER_DICTIONARY_VALUE_KEY @"_value"
#define BFWEBVIEWAPPLINKRESOLVER_PREFER_HEADER @"Prefer-Html-Meta-Tags"
#define BFWEBVIEWAPPLINKRESOLVER_META_TAG_PREFIX @"al"

@interface BFWebViewListener : NSObject <UIWebViewDelegate>

@property (nonatomic, copy) void (^didFinishLoad)(UIWebView *webView);
@property (nonatomic, copy) void (^didFailLoadWithError)(UIWebView *webView, NSError *error);
@property (nonatomic, assign) BOOL hasLoaded;

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
    if (self.hasLoaded) {
        return NO;
    }
    self.hasLoaded = YES;
    return YES;
}

@end


@implementation BFWebViewAppLinkResolver

+ (instancetype)resolver {
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
    [request setValue:BFWEBVIEWAPPLINKRESOLVER_META_TAG_PREFIX
   forHTTPHeaderField:BFWEBVIEWAPPLINKRESOLVER_PREFER_HEADER];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *connectionError) {
                               if (connectionError) {
                                   [tcs setError:connectionError];
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
                               
                               [tcs setResult:@{
                                                @"response" : response,
                                                @"data" : data
                                                }];
                           }];
    return [tcs.task continueWithSuccessBlock:^id(BFTask *task) {
        // If we redirected, just keep recursing.
        if ([task.result isKindOfClass:[NSURL class]]) {
            return [self followRedirects:task.result];
        }
        return task;
    }];
}

- (BFTask *)appLinkFromURLInBackground:(NSURL *)url {
    return [[self followRedirects:url] continueWithSuccessBlock:^id(BFTask *task) {
        NSData *responseData = task.result[@"data"];
        NSHTTPURLResponse *response = task.result[@"response"];
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
                    [tcs setResult:[self appLinkFromALData:ogData destination:url]];
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
            [webView loadData:responseData
                     MIMEType:response.MIMEType
             textEncodingName:response.textEncodingName
                      baseURL:response.URL];
            UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
            [window addSubview:webView];
        });
        
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
        if (name == (id)[NSNull null]) continue;
        NSArray *nameComponents = [name componentsSeparatedByString:@":"];
        if (![nameComponents[0] isEqualToString:BFWEBVIEWAPPLINKRESOLVER_META_TAG_PREFIX]) {
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
            root[BFWEBVIEWAPPLINKRESOLVER_DICTIONARY_VALUE_KEY] = tag[@"content"];
        }
    }
    return al;
}

- (NSDictionary *)getALDataFromLoadedPage:(UIWebView *)webView {
    // Run some JavaScript in the webview to fetch the meta tags.
    NSString *jsonString = [webView stringByEvaluatingJavaScriptFromString:BFWEBVIEWAPPLINKRESOLVER_TAG_EXTRACTION_JAVASCRIPT];
    NSError *error = nil;
    NSArray *arr = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
                                                   options:0
                                                     error:&error];
    return [self parseALData:arr];
}

/*
 Converts app link data into a BFAppLink containing the targets relevant for this platform.
 */
- (BFAppLink *)appLinkFromALData:(NSDictionary *)appLinkDict destination:(NSURL *)destination {
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
            NSArray *urls = platformDict[BFWEBVIEWAPPLINKRESOLVER_IOS_URL_KEY];
            NSArray *appStoreIds = platformDict[BFWEBVIEWAPPLINKRESOLVER_IOS_APP_STORE_ID_KEY];
            NSArray *appNames = platformDict[BFWEBVIEWAPPLINKRESOLVER_IOS_APP_NAME_KEY];
            
            NSUInteger maxCount = MAX(urls.count, MAX(appStoreIds.count, appNames.count));
            
            for (NSUInteger i = 0; i < maxCount; i++) {
                NSString *urlString = urls[i][BFWEBVIEWAPPLINKRESOLVER_DICTIONARY_VALUE_KEY];
                NSURL *url = urlString ? [NSURL URLWithString:urlString] : nil;
                NSString *appStoreId = appStoreIds[i][BFWEBVIEWAPPLINKRESOLVER_DICTIONARY_VALUE_KEY];
                NSString *appName = appNames[i][BFWEBVIEWAPPLINKRESOLVER_DICTIONARY_VALUE_KEY];
                BFAppLinkTarget *target = [BFAppLinkTarget appLinkTargetWithURL:url
                                                                     appStoreId:appStoreId
                                                                        appName:appName];
                [linkTargets addObject:target];
            }
        }
    }
    
    NSString *webUrlString = appLinkDict[@"web"][0][@"url"][0][BFWEBVIEWAPPLINKRESOLVER_DICTIONARY_VALUE_KEY];
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

@end
