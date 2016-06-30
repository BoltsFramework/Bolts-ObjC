/*
 *  Copyright (c) 2014, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

@class BFAppLink;

/*
 Builds up a data structure filled with the app link data from the meta tags on a page.
 The structure of this object is a dictionary where each key holds an array of app link
 data dictionaries.  Values are stored in a key called "_value".
 */
extern NSDictionary *BFAppLinkResolverParseALData(NSArray *dataArray);

/*
 Converts app link data into a BFAppLink containing the targets relevant for this platform.
 */
extern BFAppLink *BFAppLinkResolverAppLinkFromALData(NSDictionary *appLinkDict, NSURL *destination);

/*
 The returned task will be resolved with a dictionary containing the response data
 */
extern BFTask *BFFollowRedirects(NSURL *url);

extern NSString *const BFAppLinkResolverPreferHeader;
extern NSString *const BFAppLinkResolverMetaTagPrefix;

extern NSString *const BFAppLinkResolverRedirectDataKey;
extern NSString *const BFAppLinkResolverRedirectResponseKey;
