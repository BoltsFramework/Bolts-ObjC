/*
 *  Copyright (c) 2014, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import "BFURL.h"
#import "BFAppLink.h"
#import "BFAppLinkTarget.h"

FOUNDATION_EXPORT NSString *const BFAppLinkDataParameterName;
FOUNDATION_EXPORT NSString *const BFAppLinkTargetKeyName;
FOUNDATION_EXPORT NSString *const BFAppLinkUserAgentKeyName;
FOUNDATION_EXPORT NSString *const BFAppLinkExtrasKeyName;
FOUNDATION_EXPORT NSString *const BFAppLinkVersionKeyName;
FOUNDATION_EXPORT NSString *const BFAppLinkRefererAppLink;
FOUNDATION_EXPORT NSString *const BFAppLinkRefererAppName;
FOUNDATION_EXPORT NSString *const BFAppLinkRefererUrl;

@implementation BFURL

- (id)initWithURL:(NSURL *)url {
    if (self = [super init]) {
        _inputURL = url;
        _targetURL = url;
        
        // Parse the query string parameters for the base URL
        NSDictionary *baseQuery = [BFURL queryParametersForURL:url];
        _inputQueryParameters = baseQuery;
        _targetQueryParameters = baseQuery;
        
        // Check for applink_data
        NSString *appLinkDataString = baseQuery[BFAppLinkDataParameterName];
        if (appLinkDataString) {
            // Try to parse the JSON
            NSError *error = nil;
            NSDictionary *applinkData = [NSJSONSerialization JSONObjectWithData:[appLinkDataString dataUsingEncoding:NSUTF8StringEncoding]
                                                                        options:0
                                                                          error:&error];
            if (!error && [applinkData isKindOfClass:[NSDictionary class]]) {
                // If the version is not specified, assume it is 1.
                NSString *version = applinkData[BFAppLinkVersionKeyName] ?: @"1.0";
                NSString *target = applinkData[BFAppLinkTargetKeyName];
                if ([version isKindOfClass:[NSString class]] &&
                    [version isEqual:BFAppLinkVersion]) {
                    // There's applink data!  The target should actually be the applink target.
                    _appLinkData = applinkData;
                    NSDictionary *applinkExtras = applinkData[BFAppLinkExtrasKeyName];
                    if (applinkExtras && [applinkExtras isKindOfClass:[NSDictionary class]]) {
                        _appLinkExtras = applinkData[BFAppLinkExtrasKeyName];
                    }
                    _targetURL = target ? [NSURL URLWithString:target] : url;
                    _targetQueryParameters = [BFURL queryParametersForURL:_targetURL];

                    NSDictionary *refererAppLink = _appLinkData[BFAppLinkRefererAppLink];
                    NSString *refererURLString = refererAppLink[BFAppLinkRefererUrl];
                    NSString *refererAppName = refererAppLink[BFAppLinkRefererAppName];

                    if (refererURLString && refererAppName) {
                        BFAppLinkTarget *target = [BFAppLinkTarget appLinkTargetWithURL:[NSURL URLWithString:refererURLString]
                                                                             appStoreId:nil
                                                                                appName:refererAppName];
                        _appLinkReferer = [BFAppLink appLinkWithSourceURL:[NSURL URLWithString:refererURLString]
                                                                  targets:@[target]
                                                                   webURL:nil];
                    }
                }
            }
        }
    }
    return self;
}

+ (BFURL *)URLWithURL:(NSURL *)url {
    return [[BFURL alloc] initWithURL:url];
}

+ (NSString *)decodeURLString:(NSString *)string {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapes(NULL,
                                                                                    (CFStringRef)string,
                                                                                    CFSTR("")));
}

+ (NSDictionary *)queryParametersForURL:(NSURL *)url {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSString *query = url.query;
    if ([query isEqualToString:@""]) {
        return @{};
    }
    NSArray *queryComponents = [query componentsSeparatedByString:@"&"];
    for (NSString *component in queryComponents) {
        NSRange equalsLocation = [component rangeOfString:@"="];
        if (equalsLocation.location == NSNotFound) {
            // There's no equals, so associate the key with NSNull
            parameters[[self decodeURLString:component]] = [NSNull null];
        } else {
            NSString *key = [self decodeURLString:[component substringToIndex:equalsLocation.location]];
            NSString *value = [self decodeURLString:[component substringFromIndex:equalsLocation.location + 1]];
            parameters[key] = value;
        }
    }
    return [NSDictionary dictionaryWithDictionary:parameters];
}

@end
