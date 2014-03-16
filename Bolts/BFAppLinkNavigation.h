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

typedef NS_ENUM(NSInteger, BFAppLinkNavigationType) {
    BFAppLinkNavigationTypeFailure,
    BFAppLinkNavigationTypeBrowser,
    BFAppLinkNavigationTypeApp
};

@protocol BFAppLinkResolving;

@interface BFAppLinkNavigation : NSObject

/*! The referer_data for the AppLinkNavigation */
@property (readonly, strong) NSDictionary *appData;
/*! The al_applink_data for the AppLinkNavigation */
@property (readonly, strong) NSDictionary *navigationData;
/*! The AppLink to navigate to */
@property (readonly, strong) BFAppLink *appLink;

/* Creates an AppLinkNavigation with the given link, app data, and navigation data. */
+ (instancetype)navigationWithAppLink:(BFAppLink *)appLink
                              appData:(NSDictionary *)appData
                       navigationData:(NSDictionary *)navigationData;
/* Performs the navigation */
- (BFAppLinkNavigationType)navigate:(NSError **)error;

/*! Returns a BFAppLink for the given URL */
+ (BFTask *)resolveAppLinkInBackground:(NSURL *)destination;
/*! Returns a BFAppLink for the given URL using the given App Link resolution strategy */
+ (BFTask *)resolveAppLinkInBackground:(NSURL *)destination resolver:(id<BFAppLinkResolving>)resolver;

/*! Navigates to a BFAppLink and returns whether it opened in-app or in-browser */
+ (BFAppLinkNavigationType)navigateToAppLink:(BFAppLink *)link error:(NSError **)error;
/*! Navigates to a URL (an asynchronous action) and returns a BFNavigationType */
+ (BFTask *)navigateToURLInBackground:(NSURL *)destination;
/*!
 Navigates to a URL (an asynchronous action) using the given App Link resolution
 strategy and returns a BFNavigationType
 */
+ (BFTask *)navigateToURL:(NSURL *)destination resolver:(id<BFAppLinkResolving>)resolver;

@end
