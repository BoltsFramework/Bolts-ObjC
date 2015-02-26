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

#import "BFWebViewAppLinkResolver.h"
#import "BFAppLinkResolvingPrivate.h"
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

@interface BFWebViewAppLinkResolverWebViewDelegate : NSObject <UIWebViewDelegate>

@property (nonatomic, copy) void (^didFinishLoad)(UIWebView *webView);
@property (nonatomic, copy) void (^didFailLoadWithError)(UIWebView *webView, NSError *error);
@property (nonatomic, assign) BOOL hasLoaded;

@end

@implementation BFWebViewAppLinkResolverWebViewDelegate

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
        // Consider loading a second resource to be "success", since it indicates an inner frame
        // or redirect is happening. We can run the tag extraction script at this point.
        self.didFinishLoad(webView);
        return NO;
    }
    self.hasLoaded = YES;
    return YES;
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

- (BFTask *)appLinkFromURLInBackground:(NSURL *)url {
    return [BFFollowRedirects(url) continueWithExecutor:[BFExecutor mainThreadExecutor]
                                           withSuccessBlock:^id(BFTask *task) {
                                               NSData *responseData = task.result[BFAppLinkResolverRedirectDataKey];
                                               NSHTTPURLResponse *response = task.result[BFAppLinkResolverRedirectResponseKey];
                                               BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];

                                               UIWebView *webView = [[UIWebView alloc] init];
                                               BFWebViewAppLinkResolverWebViewDelegate *listener = [[BFWebViewAppLinkResolverWebViewDelegate alloc] init];
                                               __block BFWebViewAppLinkResolverWebViewDelegate *retainedListener = listener;
                                               listener.didFinishLoad = ^(UIWebView *view) {
                                                   if (retainedListener) {
                                                       NSDictionary *ogData = [self getALDataFromLoadedPage:view];
                                                       [view removeFromSuperview];
                                                       view.delegate = nil;
                                                       retainedListener = nil;
                                                       [tcs setResult:BFAppLinkResolverAppLinkFromALData(ogData, url)];
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

                                               return tcs.task;
                                           }];
}

- (NSDictionary *)getALDataFromLoadedPage:(UIWebView *)webView {
    // Run some JavaScript in the webview to fetch the meta tags.
    NSString *jsonString = [webView stringByEvaluatingJavaScriptFromString:BFWebViewAppLinkResolverTagExtractionJavaScript];
    NSError *error = nil;
    NSArray *arr = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
                                                   options:0
                                                     error:&error];
    return BFAppLinkResolverParseALData(arr);
}

@end
