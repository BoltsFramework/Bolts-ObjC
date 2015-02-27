/*
 *  Copyright (c) 2014, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import "BFAppLinkReturnToRefererController.h"

#import "BFAppLink.h"
#import "BFAppLinkReturnToRefererView_Internal.h"
#import "BFURL_Internal.h"

static const CFTimeInterval kBFViewAnimationDuration = 0.25f;

@interface BFAppLinkReturnToRefererController ()

@property (nonatomic, strong, readwrite) UINavigationController *attachedToNavController; // TODO rename

@end

@implementation BFAppLinkReturnToRefererController {
    BFURL *_lastShownBFUrl;
    NSURL *_lastShownUrl;
}

@synthesize view = _view;

#pragma mark - Object lifecycle

- (instancetype)init {
    return [self initForDisplayAboveNavController:nil];
}

- (instancetype)initForDisplayAboveNavController:(UINavigationController *)navController {
    self = [super init];
    if (self) {
        _attachedToNavController = navController;

        if (_attachedToNavController != nil) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(statusBarFrameWillChange:)
                                                         name:UIApplicationWillChangeStatusBarFrameNotification
                                                       object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(statusBarFrameDidChange:)
                                                         name:UIApplicationDidChangeStatusBarFrameNotification
                                                       object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(orientationDidChange:)
                                                         name:UIDeviceOrientationDidChangeNotification
                                                       object:nil];
        }
    }
    return self;
}

- (void)dealloc {
    _view.delegate = nil;

    if (_attachedToNavController) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

#pragma mark - Public API

- (BFAppLinkReturnToRefererView *)view {
    if (!_view) {
        self.view = [[BFAppLinkReturnToRefererView alloc] initWithFrame:CGRectZero];
        if (_attachedToNavController) {
            [_attachedToNavController.view addSubview:_view];
        }
    }
    return _view;
}

- (void)setView:(BFAppLinkReturnToRefererView *)view {
    if (_view != view) {
        _view.delegate = nil;
    }

    _view = view;
    _view.delegate = self;
    
    if (_attachedToNavController) {
        _view.includeStatusBarInSize = BFIncludeStatusBarInSizeAlways;
    }

    // TODO
//    _view.refererAppLink = _refererAppLink;
}

- (void)showViewForRefererAppLink:(BFAppLink *)refererAppLink {
    self.view.refererAppLink = refererAppLink;

    [_view sizeToFit];

    if (_attachedToNavController) {
        if (!_view.closed) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self moveNavigationBar];
            });
        }
    }
}

- (void)showViewForRefererURL:(NSURL *)url {
    if (![_lastShownUrl isEqual:url]) {
        _lastShownUrl = [url copy];
        _lastShownBFUrl = [BFURL URLForRenderBackToReferrerBarURL:url];
    }
    [self showViewForRefererAppLink:_lastShownBFUrl.appLinkReferer];
}

- (void)removeFromNavController {
    if (_attachedToNavController) {
        [_view removeFromSuperview];
        _attachedToNavController = nil;
    }
}

#pragma mark - BFAppLinkReturnToRefererViewDelegate

- (void)returnToRefererViewDidTapInsideCloseButton:(BFAppLinkReturnToRefererView *)view {
    [self closeViewAnimated:YES];
}

- (void)returnToRefererViewDidTapInsideLink:(BFAppLinkReturnToRefererView *)view
                                       link:(BFAppLink *)link {
    [self openRefererAppLink:link];
    [self closeViewAnimated:NO];
}

#pragma mark - Private

- (void)statusBarFrameWillChange:(NSNotification *)notification {
    NSValue* rectValue = [[notification userInfo] valueForKey:UIApplicationStatusBarFrameUserInfoKey];
    CGRect newFrame;
    [rectValue getValue:&newFrame];

    if (_attachedToNavController && !_view.closed) {
        if (newFrame.size.height == 40) {
            UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
            [UIView animateWithDuration:kBFViewAnimationDuration delay:0.0 options:options animations:^{
                _view.frame = CGRectMake(0.0, 0.0, _view.frame.size.width, 0.0);
            } completion:nil];
        }
    }
}

- (void)statusBarFrameDidChange:(NSNotification *)notification {
    NSValue* rectValue = [[notification userInfo] valueForKey:UIApplicationStatusBarFrameUserInfoKey];
    CGRect newFrame;
    [rectValue getValue:&newFrame];

    if (_attachedToNavController && !_view.closed) {
        if (newFrame.size.height == 40) {
            UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
            [UIView animateWithDuration:kBFViewAnimationDuration delay:0.0 options:options animations:^{
                [_view sizeToFit];
                [self moveNavigationBar];
            } completion:nil];
        }
    }
}

- (void)orientationDidChange:(NSNotificationCenter *)notification {
    if (_attachedToNavController && !_view.closed && _view.frame.size.height > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self moveNavigationBar];
        });
    }
}

- (void)moveNavigationBar {
    if (_view.closed || !_view.refererAppLink) {
      return;
    }

    CGRect oldFrame = _attachedToNavController.navigationBar.frame;

    _attachedToNavController.navigationBar.frame = CGRectMake(0,
                                                              _view.frame.size.height,
                                                              _attachedToNavController.navigationBar.frame.size.width,
                                                              _attachedToNavController.navigationBar.frame.size.height);

    CGFloat dy = CGRectGetMaxY(_attachedToNavController.navigationBar.frame) - CGRectGetMaxY(oldFrame);
    UIView *navigationView = _attachedToNavController.visibleViewController.view.superview;
    navigationView.frame = CGRectMake(navigationView.frame.origin.x,
                                      navigationView.frame.origin.y + dy,
                                      navigationView.frame.size.width,
                                      navigationView.frame.size.height - dy);

}

- (void)closeViewAnimated:(BOOL)animated {
    void (^closer)(void) = ^{
        if (_attachedToNavController) {
            CGRect oldFrame = _attachedToNavController.navigationBar.frame;

            _attachedToNavController.navigationBar.frame = CGRectMake(0,
                                                                      _view.statusBarHeight,
                                                                      _attachedToNavController.navigationBar.frame.size.width,
                                                                      _attachedToNavController.navigationBar.frame.size.height);

            CGFloat dy = CGRectGetMaxY(_attachedToNavController.navigationBar.frame) - CGRectGetMaxY(oldFrame);
            UIView *navigationView = _attachedToNavController.visibleViewController.view.superview;
            navigationView.frame = CGRectMake(navigationView.frame.origin.x,
                                              navigationView.frame.origin.y + dy,
                                              navigationView.frame.size.width,
                                              navigationView.frame.size.height - dy);
        }

        _view.frame = CGRectMake(_view.frame.origin.x,
                                 _view.frame.origin.y,
                                 _view.frame.size.width,
                                 0);
    };

    if (animated) {
        UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
        [UIView animateWithDuration:kBFViewAnimationDuration delay:0.0 options:options animations:^{
            closer();
        } completion:^(BOOL animateOutFinished) {
            _view.closed = YES;
        }];
    } else {
        closer();
        _view.closed = YES;
    }
}

- (void)openRefererAppLink:(BFAppLink *)refererAppLink {
    if (refererAppLink) {
        id<BFAppLinkReturnToRefererControllerDelegate> delegate = _delegate;
        if ([delegate respondsToSelector:@selector(returnToRefererController:willNavigateToAppLink:)]) {
            [delegate returnToRefererController:self willNavigateToAppLink:refererAppLink];
        }

        NSError *error = nil;
        BFAppLinkNavigationType type = [BFAppLinkNavigation navigateToAppLink:refererAppLink error:&error];

        if ([delegate respondsToSelector:@selector(returnToRefererController:didNavigateToAppLink:type:)]) {
            [delegate returnToRefererController:self didNavigateToAppLink:refererAppLink type:type];
        }
    }
}


@end
