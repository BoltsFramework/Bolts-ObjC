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
#import "BFWebViewAppLinkResolver.h"

@interface BFNavigator ()

@end

@implementation BFNavigator

+ (BFTask *)resolveAppLink:(NSURL *)destination resolver:(id)resolver {
    return [resolver appLinkFromURLAsync:destination];
}

+ (BFTask *)resolveAppLink:(NSURL *)destination {
    return [self resolveAppLink:destination resolver:[BFWebViewAppLinkResolver resolver]];
}

+ (BFTask *)navigateToURL:(NSURL *)destination {
    return [self navigateToURL:destination
                       headers:nil
                      resolver:[BFWebViewAppLinkResolver resolver]];
}

+ (BFTask *)navigateToURL:(NSURL *)destination resolver:(id<BFAppLinkResolving>)resolver {
    return [self navigateToURL:destination
                       headers:nil
                      resolver:resolver];
}

+ (BFTask *)navigateToURL:(NSURL *)destination headers:(NSDictionary *)headers {
    return [self navigateToURL:destination
                       headers:headers
                      resolver:[BFWebViewAppLinkResolver resolver]];
}

+ (BFTask *)navigateToURL:(NSURL *)destination
                  headers:(NSDictionary *)headers
                 resolver:(id<BFAppLinkResolving>)resolver {
    return [[self resolveAppLink:destination
                        resolver:resolver] continueWithSuccessBlock:^id(BFTask *task) {
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
