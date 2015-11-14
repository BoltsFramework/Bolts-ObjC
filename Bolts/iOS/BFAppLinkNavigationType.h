//
//  BFAppLinkNavigationType.h
//  Bolts
//
//  Created by Marcel Bradea on 2015-10-31.
//  Copyright © 2015 Parse Inc. All rights reserved.
//

/*!
 The result of calling navigate on a BFAppLinkNavigation
 */
typedef NS_ENUM(NSInteger, BFAppLinkNavigationType) {
    /*! Indicates that the navigation failed and no app was opened */
    BFAppLinkNavigationTypeFailure,
    /*! Indicates that the navigation succeeded by opening the URL in the browser */
    BFAppLinkNavigationTypeBrowser,
    /*! Indicates that the navigation succeeded by opening the URL in an app on the device */
    BFAppLinkNavigationTypeApp
};
