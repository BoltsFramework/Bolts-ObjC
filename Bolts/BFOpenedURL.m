/*
 *  Copyright (c) 2014, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import "BFOpenedURL.h"
#import "BFAppLink.h"

@implementation BFOpenedURL

- (id)initWithURL:(NSURL *)url {
    if (self = [super init]) {
        _baseURL = url;
        _targetURL = url;
        
        // Parse the query string parameters for the base URL
        NSDictionary *baseQuery = [BFOpenedURL queryParametersForURL:url];
        _baseQueryParameters = baseQuery;
        _targetQueryParameters = baseQuery;
        
        // Check for applink_data
        NSString *appLinkDataString = baseQuery[BFAPPLINK_DATA_PARAMETER_NAME];
        if (appLinkDataString) {
            // Try to parse the JSON
            NSError *error = nil;
            NSDictionary *applinkData = [NSJSONSerialization JSONObjectWithData:[appLinkDataString dataUsingEncoding:NSUTF8StringEncoding]
                                                                        options:0
                                                                          error:&error];
            if (!error && [applinkData isKindOfClass:[NSDictionary class]]) {
                NSString *target = applinkData[BFAPPLINK_TARGET_HEADER_NAME];
                if (target) {
                    // There's applink data!  The target should actually be the applink target.
                    _appLinkHeaders = applinkData;
                    _targetURL = [NSURL URLWithString:target];
                    _targetQueryParameters = [BFOpenedURL queryParametersForURL:_targetURL];
                }
            }
        }
    }
    return self;
}

+ (BFOpenedURL *)openedURLFromURL:(NSURL *)url {
    return [[BFOpenedURL alloc] initWithURL:url];
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
