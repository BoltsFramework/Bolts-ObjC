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

@class BFAppLinkReturnToRefererView;
@class BFURL;

/*!
 Protocol that a class can implement in order to be notified when the user has navigated back
 to the referer of an App Link.
 */
@protocol BFAppLinkReturnToRefererViewDelegate <NSObject>

@optional

/*! Called when the user has tapped to navigate, but before the navigation has been performed. */
- (void)returnToRefererView:(BFAppLinkReturnToRefererView *)view
                willOpenURL:(NSURL *)url;

/*! Called after the navigation has been attempted, with an indication of whether the referer
 URL was successfully opened. */
- (void)returnToRefererView:(BFAppLinkReturnToRefererView *)view
                 didOpenURL:(NSURL *)url
                    success:(BOOL)success;

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

/*!
 The URL representing the App Link whose referer data is currently being displayed.
 If nil, or if the App Link does not contain any referer data, no UI will be displayed.
 If the App Link does contain referer data, the view will be resized to display it.
 */
@property (readwrite, strong, nonatomic) BFURL* url;

/*!
 The name of the referer currently being displayed.
 */
@property (readonly) NSString *refererName;

/*!
 The URL that will be used to navigate back to the referer if the user taps on the button.
 */
@property (readonly) NSURL *refererURL;

/*! 
 Indicates whether to extend the size of the view to include the current status bar
 size, for use in scenarios where the view might extend under the status bar on iOS 7 and
 above; this property has no effect on earlier versions of iOS. 
 */
@property (readwrite, assign, nonatomic) BOOL includeStatusBarInSize;

/*!
 Indicates whether the user has closed the view by clicking the close button.
 */
@property (readonly, assign, nonatomic) BOOL closed;

/*!
 Initializes a BFAppLinkReturnToRefererView and extracts referer data from the App Link
 represented by an NSURL.
 */
- (instancetype)initWithNSURL:(NSURL *)url;

/*!
 Initializes a BFAppLinkReturnToRefererView and extracts referer data from the App Link
 represented by an BFURL.
 */
- (instancetype)initWithBFURL:(BFURL *)url;

/*!
 Closes the view, as if the user had clicked the close button.
 */
- (void)closeAnimated:(BOOL)animated;

/*!
 For apps that use a navigation controller, this method allows for displaying the view as
 a banner above the navigation bar of the navigation controller. It will listen for orientation
 change and other events to ensure it stays properly positioned above the nevigation bar.
 If this method is called from, e.g., viewDidAppear, its counterpart, detachFromMainWindow should
 be called from, e.g., viewWillDisappear.
 */
- (void)attachToMainWindowAboveNavigationController:(UINavigationController *)navigationController view:(UIView *)view;

/*!
 Indicates that the view should no longer position itself above a navigation bar.
 */
- (void)detachFromMainWindow;

/*!
 Creates a BFAppLinkReturnToRefererView and extracts referer data from the App Link
 represented by an NSURL.
 */
+ (instancetype)viewWithNSURL:(NSURL *)url;

/*!
 Creates a BFAppLinkReturnToRefererView and extracts referer data from the App Link
 represented by an BFURL.
 */
+ (instancetype)viewWithBFURL:(BFURL *)url;

@end
