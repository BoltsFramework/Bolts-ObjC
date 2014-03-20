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

FOUNDATION_EXPORT NSString *const BFAppLinkDataParameterName;
FOUNDATION_EXPORT NSString *const BFAppLinkTargetKeyName;
FOUNDATION_EXPORT NSString *const BFAppLinkUserAgentKeyName;
FOUNDATION_EXPORT NSString *const BFAppLinkRefererDataKeyName;
FOUNDATION_EXPORT NSString *const BFAppLinkVersionKeyName;

@implementation BFURL

- (id)initWithURL:(NSURL *)url {
    if (self = [super init]) {
        _originalURL = url;
        _targetURL = url;
        
        // Parse the query string parameters for the base URL
        NSDictionary *baseQuery = [BFURL queryParametersForURL:url];
        _originalQueryParameters = baseQuery;
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
                NSNumber *version = applinkData[BFAppLinkVersionKeyName] ?: @1;
                NSString *target = applinkData[BFAppLinkTargetKeyName];
                if ([target isKindOfClass:[NSString class]] &&
                    [version isKindOfClass:[NSNumber class]] &&
                    [version unsignedIntegerValue] == BFAppLinkVersion) {
                    // There's applink data!  The target should actually be the applink target.
                    _appLinkNavigationData = applinkData;
                    NSDictionary *refererData = applinkData[BFAppLinkRefererDataKeyName];
                    if (refererData && [refererData isKindOfClass:[NSDictionary class]]) {
                        _appLinkAppData = applinkData[BFAppLinkRefererDataKeyName];
                    }
                    _targetURL = [NSURL URLWithString:target];
                    _targetQueryParameters = [BFURL queryParametersForURL:_targetURL];
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
