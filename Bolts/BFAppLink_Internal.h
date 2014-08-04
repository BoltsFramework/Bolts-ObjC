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

@interface BFAppLink (Internal)

+ (instancetype)appLinkWithSourceURL:(NSURL *)sourceURL
                             targets:(NSArray *)targets
                              webURL:(NSURL *)webURL
                    isBackToReferrer:(BOOL)isBackToReferrer;

/*! return if this AppLink is to go back to referrer. */
- (BOOL)isBackToReferrer;

@end