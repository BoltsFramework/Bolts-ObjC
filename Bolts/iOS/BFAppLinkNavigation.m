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

#import "BFAppLinkNavigation.h"
#import "BFTaskCompletionSource.h"
#import "BFAppLinkTarget.h"
#import "BoltsVersion.h"
#import "BFWebViewAppLinkResolver.h"
#import "BFExecutor.h"
#import "BFTask.h"

FOUNDATION_EXPORT NSString *const BFAppLinkDataParameterName;
FOUNDATION_EXPORT NSString *const BFAppLinkTargetKeyName;
FOUNDATION_EXPORT NSString *const BFAppLinkUserAgentKeyName;
FOUNDATION_EXPORT NSString *const BFAppLinkExtrasKeyName;
FOUNDATION_EXPORT NSString *const BFAppLinkVersionKeyName;

static id<BFAppLinkResolving> defaultResolver;

@interface BFAppLinkNavigation ()

@end

@implementation BFAppLinkNavigation

+ (instancetype)navigationWithAppLink:(BFAppLink *)appLink
                               extras:(NSDictionary *)extras
                          appLinkData:(NSDictionary *)appLinkData {
    BFAppLinkNavigation *navigation = [[self alloc] init];
    navigation->_appLink = appLink;
    navigation->_extras = extras;
    navigation->_appLinkData = appLinkData;
    return navigation;
}

- (NSString *)stringByEscapingQueryString:(NSString *)string {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (CFStringRef)string,
                                                                                 NULL,
                                                                                 (CFStringRef)@":/?#[]@!$&'()*+,;=",
                                                                                 kCFStringEncodingUTF8));
}

- (NSURL *)appLinkURLWithTargetURL:(NSURL *)targetUrl error:(NSError **)error {
    NSMutableDictionary *appLinkData = [NSMutableDictionary dictionaryWithDictionary:self.appLinkData ?: @{}];
    
    // Add applink protocol data
    if (!appLinkData[BFAppLinkUserAgentKeyName]) {
        appLinkData[BFAppLinkUserAgentKeyName] = [NSString stringWithFormat:@"Bolts iOS %@", BOLTS_VERSION];
    }
    if (!appLinkData[BFAppLinkVersionKeyName]) {
        appLinkData[BFAppLinkVersionKeyName] = BFAppLinkVersion;
    }
    appLinkData[BFAppLinkTargetKeyName] = [self.appLink.sourceURL absoluteString];
    appLinkData[BFAppLinkExtrasKeyName] = self.extras ?: @{};
    
    // JSON-ify the applink data
    NSError *jsonError = nil;
    NSData *jsonBlob = [NSJSONSerialization dataWithJSONObject:appLinkData options:0 error:&jsonError];
    if (!jsonError) {
        NSString *jsonString = [[NSString alloc] initWithData:jsonBlob encoding:NSUTF8StringEncoding];
        NSString *encoded = [self stringByEscapingQueryString:jsonString];
        
        NSString *endUrlString = [NSString stringWithFormat:@"%@%@%@=%@",
                                  [targetUrl absoluteString],
                                  targetUrl.query ? @"&" : @"?",
                                  BFAppLinkDataParameterName,
                                  encoded];
        
        return [NSURL URLWithString:endUrlString];
    } else {
        if (error) {
            *error = jsonError;
        }
        
        // If there was an error encoding the app link data, fail hard.
        return nil;
    }
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
        NSError *encodingError = nil;
        NSURL *appLinkURL = [self appLinkURLWithTargetURL:eligibleTarget.URL error:&encodingError];
        if (encodingError || !appLinkURL) {
            // If there was an error encoding the app link data, fail hard.
            if (error) {
                *error = encodingError;
            }
            return BFAppLinkNavigationTypeFailure;
        }
        // Attempt to navigate
        if ([[UIApplication sharedApplication] openURL:appLinkURL]) {
            return BFAppLinkNavigationTypeApp;
        }
    }
    
    // Fall back to opening the url in the browser if available.
    if (self.appLink.webURL) {
        NSError *encodingError = nil;
        NSURL *appLinkURL = [self appLinkURLWithTargetURL:self.appLink.webURL error:&encodingError];
        if (encodingError || !appLinkURL) {
            // If there was an error encoding the app link data, fail hard.
            if (error) {
                *error = encodingError;
            }
            return BFAppLinkNavigationTypeFailure;
        }
        // Attempt to navigate
        if ([[UIApplication sharedApplication] openURL:appLinkURL]) {
            // This was a browser navigation.
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
    return [self resolveAppLinkInBackground:destination resolver:[self defaultResolver]];
}

+ (BFTask *)navigateToURLInBackground:(NSURL *)destination {
    return [self navigateToURLInBackground:destination
                                  resolver:[self defaultResolver]];
}

+ (BFTask *)navigateToURLInBackground:(NSURL *)destination
                             resolver:(id<BFAppLinkResolving>)resolver {
    BFTask *resolutionTask =[self resolveAppLinkInBackground:destination
                                                    resolver:resolver];
    return [resolutionTask continueWithExecutor:[BFExecutor mainThreadExecutor]
                               withSuccessBlock:^id(BFTask *task) {
                                   NSError *error = nil;
                                   BFAppLinkNavigationType result = [self navigateToAppLink:task.result
                                                                                      error:&error];
                                   if (error) {
                                       return [BFTask taskWithError:error];
                                   } else {
                                       return @(result);
                                   }
                               }];
}

+ (BFAppLinkNavigationType)navigateToAppLink:(BFAppLink *)link error:(NSError **)error {
    return [[BFAppLinkNavigation navigationWithAppLink:link
                                                extras:nil
                                           appLinkData:nil] navigate:error];;
}

+ (id<BFAppLinkResolving>)defaultResolver {
    if (defaultResolver) {
        return defaultResolver;
    }
    return [BFWebViewAppLinkResolver sharedInstance];
}

+ (void)setDefaultResolver:(id<BFAppLinkResolving>)resolver {
    defaultResolver = resolver;
}

@end
