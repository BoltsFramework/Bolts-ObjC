/*
 *  Copyright (c) 2014, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import "BFAppLink.h"

NSString *const BFAppLinkDataParameterName = @"al_applink_data";
NSString *const BFAppLinkTargetKeyName = @"target_url";
NSString *const BFAppLinkUserAgentKeyName = @"user_agent";
NSString *const BFAppLinkExtrasKeyName = @"extras";
NSString *const BFAppLinkRefererAppLink = @"referer_app_link";
NSString *const BFAppLinkRefererAppName = @"app_name";
NSString *const BFAppLinkRefererUrl = @"url";
NSString *const BFAppLinkVersionKeyName = @"version";
NSString *const BFAppLinkVersion = @"1.0";

@implementation BFAppLink

+ (instancetype)appLinkWithSourceURL:(NSURL *)sourceURL
                             targets:(NSArray *)targets
                              webURL:(NSURL *)webURL {
    BFAppLink *link = [[self alloc] init];
    link->_sourceURL = sourceURL;
    link->_targets = [NSArray arrayWithArray:targets];
    link->_webURL = webURL;
    return link;
}

@end
