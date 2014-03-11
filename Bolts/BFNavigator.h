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

#import "BFTask.h"
#import "BFAppLink.h"

typedef NS_ENUM(NSInteger, BFNavigationType) {
    BFNavigationTypeFailure,
    BFNavigationTypeBrowser,
    BFNavigationTypeApp
};

@protocol BFAppLinkResolving;

@interface BFNavigator : NSObject

/*! Returns a BFAppLink for the given URL */
+ (BFTask *)resolveAppLinkInBackground:(NSURL *)destination;
/*! Returns a BFAppLink for the given URL using the given App Link resolution strategy */
+ (BFTask *)resolveAppLinkInBackground:(NSURL *)destination resolver:(id<BFAppLinkResolving>)resolver;

/*! Navigates to a BFAppLink and returns whether it opened in-app or in-browser */
+ (BFNavigationType)navigateToAppLink:(BFAppLink *)link error:(NSError **)error;
/*! Navigates to a BFAppLink with the given headers and returns whether it opened in-app or in-browser */
+ (BFNavigationType)navigateToAppLink:(BFAppLink *)link headers:(NSDictionary *)headers error:(NSError **)error;

/*! Navigates to a URL (an asynchronous action) and returns a BFNavigationType */
+ (BFTask *)navigateToURLInBackground:(NSURL *)destination;
/*! Navigates to a URL (an asynchronous action) with the given headers and returns a BFNavigationType */
+ (BFTask *)navigateToURLInBackground:(NSURL *)destination headers:(NSDictionary *)headers;
/*!
 Navigates to a URL (an asynchronous action) using the given App Link resolution
 strategy and returns a BFNavigationType
 */
+ (BFTask *)navigateToURL:(NSURL *)destination resolver:(id<BFAppLinkResolving>)resolver;
/*!
 Navigates to a URL (an asynchronous action) with the given headers using the given App Link
 resolution strategy and returns a BFNavigationType
 */
+ (BFTask *)navigateToURLInBackground:(NSURL *)destination
                              headers:(NSDictionary *)headers
                             resolver:(id<BFAppLinkResolving>)resolver;

@end
