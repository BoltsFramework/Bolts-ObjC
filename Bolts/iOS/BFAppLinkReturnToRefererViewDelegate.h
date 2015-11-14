//
//  BFAppLinkReturnToRefererViewDelegate.h
//  Bolts
//
//  Created by Marcel Bradea on 2015-10-31.
//  Copyright © 2015 Parse Inc. All rights reserved.
//

@class BFAppLinkReturnToRefererView;
@class BFAppLink;

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
