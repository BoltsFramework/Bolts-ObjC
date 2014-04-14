/*
 *  Copyright (c) 2014, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import <UIKit/UIKit.h>

#import "BFAppLinkNavigation.h"

@class BFAppLinkReturnToRefererView;
@class BFURL;

typedef enum BFIncludeStatusBarInSize {
  BFIncludeStatusBarInSizeNever,
  BFIncludeStatusBarInSizeIOS7AndLater,
  BFIncludeStatusBarInSizeAlways,
} BFIncludeStatusBarInSize;

/*!
 Protocol that a class can implement in order to be notified when the user has navigated back
 to the referer of an App Link.
 */
@protocol BFAppLinkReturnToRefererViewDelegate <NSObject>

/*!
 Called when the user has tapped inside the close button.
 */
- (void)returnToRefererViewDidTapInsideCloseButton:(BFAppLinkReturnToRefererView *)view;

/*!
 Called when the user has tapped inside the App Link portion of the view.
 */
- (void)returnToRefererViewDidTapInsideLink:(BFAppLinkReturnToRefererView *)view
                                       link:(BFAppLink *)link;

@end

/*!
 Provides a UIView that displays a button allowing users to navigate back to the
 application that launched the App Link currently being handled, if the App Link
 contained referer data. The user can also close the view by clicking a close button
 rather than navigating away. If the view is provided an App Link that does not contain
 referer data, it will have zero size and no UI will be displayed.
 */
@interface BFAppLinkReturnToRefererView : UIView

/*!
 The delegate that will be notified when the user navigates back to the referer.
 */
@property (readwrite, weak, nonatomic) id<BFAppLinkReturnToRefererViewDelegate> delegate;

/*!
 The color of the text label and close button.
 */
@property (readwrite, strong, nonatomic) UIColor *textColor;

@property (readwrite, strong, nonatomic) BFAppLink *refererAppLink;

/*!
 Indicates whether to extend the size of the view to include the current status bar
 size, for use in scenarios where the view might extend under the status bar on iOS 7 and
 above; this property has no effect on earlier versions of iOS. 
 */
@property (readwrite, assign, nonatomic) BFIncludeStatusBarInSize includeStatusBarInSize;

/*!
 Indicates whether the user has closed the view by clicking the close button.
 */
@property (readwrite, assign, nonatomic) BOOL closed;

/*!
 For apps that use a navigation controller, this method allows for displaying the view as
 a banner above the navigation bar of the navigation controller. It will listen for orientation
 change and other events to ensure it stays properly positioned above the nevigation bar.
 If this method is called from, e.g., viewDidAppear, its counterpart, detachFromMainWindow should
 be called from, e.g., viewWillDisappear.
 */
//- (void)attachToMainWindowAboveNavigationController:(UINavigationController *)navigationController view:(UIView *)view;

/*!
 Indicates that the view should no longer position itself above a navigation bar.
 */
//- (void)detachFromMainWindow;

@end
