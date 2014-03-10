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

@interface BFOpenedURL : NSObject

/*!
 Creates a link target from a raw URL. Usually, this will be used to parse a URL passed into
 an app delegate's handleOpenURL: method.
 */
+ (BFOpenedURL *)openedURLFromURL:(NSURL *)url;

/*!
 Gets the target URL.  If the link is an AppLink, this is the target of the AppLink.
 Otherwise, it is the url that created the target.
 */
@property (readonly, strong) NSURL *targetURL;

/*!
 Gets the query parameters for the target, parsed into an NSDictionary.
 */
@property (readonly, strong) NSDictionary *targetQueryParameters;

/*!
 If this link target is an AppLink, this is the set of headers included in the applink_data.
 Otherwise, it is nil.
 */
@property (readonly, strong) NSDictionary *appLinkHeaders;

/*!
 The URL that was used to create this link target.
 */
@property (readonly, strong) NSURL *baseURL;

/*!
 The query parameters of the base URL, parsed into an NSDictionary.
 */
@property (readonly, strong) NSDictionary *baseQueryParameters;

@end
