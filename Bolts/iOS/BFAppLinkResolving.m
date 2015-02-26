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

#import "BFAppLinkResolving.h"
#import "BFAppLinkResolvingPrivate.h"
#import "BFAppLink.h"
#import "BFAppLinkTarget.h"
#import "BFTask.h"
#import "BFTaskCompletionSource.h"

NSString *const BFAppLinkResolverPreferHeader = @"Prefer-Html-Meta-Tags";
NSString *const BFAppLinkResolverMetaTagPrefix = @"al";

NSString *const BFAppLinkResolverRedirectDataKey = @"data";
NSString *const BFAppLinkResolverRedirectResponseKey = @"response";

static NSString *const BFAppLinkResolverIOSURLKey = @"url";
static NSString *const BFAppLinkResolverIOSAppStoreIdKey = @"app_store_id";
static NSString *const BFAppLinkResolverIOSAppNameKey = @"app_name";
static NSString *const BFAppLinkResolverDictionaryValueKey = @"_value";
static NSString *const BFAppLinkResolverWebKey = @"web";
static NSString *const BFAppLinkResolverIOSKey = @"ios";
static NSString *const BFAppLinkResolverIPhoneKey = @"iphone";
static NSString *const BFAppLinkResolverIPadKey = @"ipad";
static NSString *const BFAppLinkResolverWebURLKey = @"url";
static NSString *const BFAppLinkResolverShouldFallbackKey = @"should_fallback";

NSDictionary *BFAppLinkResolverParseALData(NSArray *dataArray) {
    NSMutableDictionary *al = [NSMutableDictionary dictionary];
    for (NSDictionary *tag in dataArray) {
        NSString *name = tag[@"property"];
        if (![name isKindOfClass:[NSString class]]) {
            continue;
        }
        NSArray *nameComponents = [name componentsSeparatedByString:@":"];
        if (![nameComponents[0] isEqualToString:BFAppLinkResolverMetaTagPrefix]) {
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
            root[BFAppLinkResolverDictionaryValueKey] = tag[@"content"];
        }
    }
    return al;
}

BFAppLink *BFAppLinkResolverAppLinkFromALData(NSDictionary *appLinkDict, NSURL *destination) {
    NSMutableArray *linkTargets = [NSMutableArray array];
    
    NSArray *platformData = nil;
    switch (UI_USER_INTERFACE_IDIOM()) {
        case UIUserInterfaceIdiomPad:
            platformData = @[ appLinkDict[BFAppLinkResolverIPadKey] ?: @{},
                              appLinkDict[BFAppLinkResolverIOSKey] ?: @{} ];
            break;
        case UIUserInterfaceIdiomPhone:
            platformData = @[ appLinkDict[BFAppLinkResolverIPhoneKey] ?: @{},
                              appLinkDict[BFAppLinkResolverIOSKey] ?: @{} ];
            break;
#ifdef __TVOS_9_0
        case UIUserInterfaceIdiomTV:
#endif
#ifdef __IPHONE_9_3
        case UIUserInterfaceIdiomCarPlay:
#endif
        case UIUserInterfaceIdiomUnspecified:
        default:
            // Future-proofing. Other User Interface idioms should only hit ios.
            platformData = @[ appLinkDict[BFAppLinkResolverIOSKey] ?: @{} ];
            break;
    }
    
    for (NSArray *platformObjects in platformData) {
        for (NSDictionary *platformDict in platformObjects) {
            // The schema requires a single url/app store id/app name,
            // but we could find multiple of them. We'll make a best effort
            // to interpret this data.
            NSArray *urls = platformDict[BFAppLinkResolverIOSURLKey];
            NSArray *appStoreIds = platformDict[BFAppLinkResolverIOSAppStoreIdKey];
            NSArray *appNames = platformDict[BFAppLinkResolverIOSAppNameKey];
            
            NSUInteger maxCount = MAX(urls.count, MAX(appStoreIds.count, appNames.count));
            
            for (NSUInteger i = 0; i < maxCount; i++) {
                NSString *urlString = urls[i][BFAppLinkResolverDictionaryValueKey];
                NSURL *url = urlString ? [NSURL URLWithString:urlString] : nil;
                NSString *appStoreId = appStoreIds[i][BFAppLinkResolverDictionaryValueKey];
                NSString *appName = appNames[i][BFAppLinkResolverDictionaryValueKey];
                BFAppLinkTarget *target = [BFAppLinkTarget appLinkTargetWithURL:url
                                                                     appStoreId:appStoreId
                                                                        appName:appName];
                [linkTargets addObject:target];
            }
        }
    }
    
    NSDictionary *webDict = appLinkDict[BFAppLinkResolverWebKey][0];
    NSString *webUrlString = webDict[BFAppLinkResolverWebURLKey][0][BFAppLinkResolverDictionaryValueKey];
    NSString *shouldFallbackString = webDict[BFAppLinkResolverShouldFallbackKey][0][BFAppLinkResolverDictionaryValueKey];
    
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

BFTask *BFFollowRedirects(NSURL *url) {
    // This task will be resolved with either the redirect NSURL
    // or a dictionary with the response data to be returned.
    BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:BFAppLinkResolverMetaTagPrefix forHTTPHeaderField:BFAppLinkResolverPreferHeader];
    
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
        
        [tcs setResult:@{ BFAppLinkResolverRedirectResponseKey : response, BFAppLinkResolverRedirectDataKey : data }];
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
            return BFFollowRedirects(task.result);
        }
        return task;
    }];
}

