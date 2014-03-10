/*
 *  Copyright (c) 2014, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import <Foundation/Foundation.h>

#define BFAPPLINK_DATA_PARAMETER_NAME @"al_applink_data"
#define BFAPPLINK_TARGET_HEADER_NAME @"target_url"
#define BFAPPLINK_USER_AGENT_HEADER_NAME @"user_agent"
#define BFAPPLINK_REFERER_HEADER_NAME @"referer"

@interface BFAppLink : NSObject

/*!
 Creates a BFAppLink with the given list of BFAppLinkTargets and target URL.
 @param sourceURL the URL from which this App Link is derived
 @param targets an ordered list of BFAppLinkTargets for this platform derived
 from App Link metadata.
 @param webURL the fallback web URL, if any, for the app link.
 */
+ (instancetype)appLinkWithSourceURL:(NSURL *)sourceURL
                             targets:(NSArray *)targets
                              webURL:(NSURL *)webURL;

/*! The URL from which this BFAppLink was derived */
@property (copy, readonly) NSURL *sourceURL;

/*!
 The ordered list of targets applicable to this platform that will be used
 for navigation.
 */
@property (strong, readonly) NSArray *targets;

/*! The fallback web URL to use if no targets are installed on this device. */
@property (copy, readonly) NSURL *webURL;

@end
