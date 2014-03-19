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

#import "BFAppLinkRequest.h"
#import "BFTaskCompletionSource.h"
#import "BFAppLinkTarget.h"
#import "BoltsVersion.h"
#import "BFWebViewAppLinkResolver.h"

@interface BFAppLinkRequest ()

@end

@implementation BFAppLinkRequest

+ (instancetype)navigationWithAppLink:(BFAppLink *)appLink
                              appData:(NSDictionary *)appData
                       navigationData:(NSDictionary *)navigationData {
    BFAppLinkRequest *navigation = [[self alloc] init];
    navigation->_appLink = appLink;
    navigation->_appData = appData;
    navigation->_navigationData = navigationData;
    return navigation;
}

- (NSString *)stringByEscapingQueryString:(NSString *)string {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (CFStringRef)string,
                                                                                 NULL,
                                                                                 (CFStringRef)@":/?#[]@!$&'()*+,;=",
                                                                                 kCFStringEncodingUTF8));
}

- (BFAppLinkNavigationType)navigate:(NSError **)error {
    // Find the first eligible/launchable target in the BFAppLink.
    BFAppLinkTarget *eligibleTarget = nil;
    for (BFAppLinkTarget *target in self.appLink.targets) {
        if ([[UIApplication sharedApplication] canOpenURL:target.URL]) {
            eligibleTarget = target;
            break;
        }
    }
    
    if (eligibleTarget) {
        NSURL *targetUrl = eligibleTarget.URL;
        NSMutableDictionary *appLinkData = [NSMutableDictionary dictionaryWithDictionary:self.navigationData ?: @{}];
        
        // Add applink protocol data
        if (!appLinkData[BFAPPLINK_USER_AGENT_KEY_NAME]) {
            appLinkData[BFAPPLINK_USER_AGENT_KEY_NAME] = [NSString stringWithFormat:@"Bolts iOS %@", BOLTS_VERSION];
        }
        if (!appLinkData[BFAPPLINK_VERSION_KEY_NAME]) {
            appLinkData[BFAPPLINK_VERSION_KEY_NAME] = @(BFAPPLINK_VERSION);
        }
        appLinkData[BFAPPLINK_TARGET_KEY_NAME] = [self.appLink.sourceURL absoluteString];
        appLinkData[BFAPPLINK_REFERER_DATA_KEY_NAME] = self.appData ?: @{};
        
        // JSON-ify the applink data
        NSError *jsonError = nil;
        NSData *jsonBlob = [NSJSONSerialization dataWithJSONObject:appLinkData options:0 error:&jsonError];
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
                return BFAppLinkNavigationTypeApp;
            }
        } else {
            if (error) {
                *error = jsonError;
            }
            
            // If there was an error encoding the app link data, fail hard.
            return BFAppLinkNavigationTypeFailure;
        }
    }
    
    // Fall back to opening the url in the browser if available.
    if (self.appLink.webURL) {
        if ([[UIApplication sharedApplication] openURL:self.appLink.webURL]) {
            return BFAppLinkNavigationTypeBrowser;
        }
    }
    
    // Otherwise, navigation fails.
    return BFAppLinkNavigationTypeFailure;
    
}

+ (BFTask *)resolveAppLinkInBackground:(NSURL *)destination resolver:(id)resolver {
    return [resolver appLinkFromURLInBackground:destination];
}

+ (BFTask *)resolveAppLinkInBackground:(NSURL *)destination {
    return [self resolveAppLinkInBackground:destination resolver:[BFWebViewAppLinkResolver sharedInstance]];
}

+ (BFTask *)navigateToURLInBackground:(NSURL *)destination {
    return [self navigateToURLInBackground:destination
                      resolver:[BFWebViewAppLinkResolver sharedInstance]];
}

+ (BFTask *)navigateToURLInBackground:(NSURL *)destination
                 resolver:(id<BFAppLinkResolving>)resolver {
    return [[self resolveAppLinkInBackground:destination
                        resolver:resolver] continueWithSuccessBlock:^id(BFTask *task) {
        BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = nil;
            BFAppLinkNavigationType result = [self navigateToAppLink:task.result error:&error];
            if (error) {
                [tcs setError:error];
            } else {
                [tcs setResult:@(result)];
            }
        });
        return tcs.task;
    }];
}

+ (BFAppLinkNavigationType)navigateToAppLink:(BFAppLink *)link error:(NSError **)error {
    return [[BFAppLinkRequest navigationWithAppLink:link
                                               appData:nil
                                        navigationData:nil] navigate:error];;
}

@end
