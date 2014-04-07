/*
 *  Copyright (c) 2014, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import "BFAppLinkReturnToRefererView.h"
#import "BFURL.h"

static const CGFloat BFMarginX = 8.5f;
static const CGFloat BFMarginY = 8.5f;

static NSString *const BFRefererAppLink = @"referer_app_link";
static NSString *const BFRefererName = @"app_name";
static NSString *const BFRefererUrl = @"url";
static const CFTimeInterval kBFViewAnimationDuration = 0.25;
static const CGFloat BFCloseButtonWidth = 12.0;
static const CGFloat BFCloseButtonHeight = 12.0;

@interface BFAppLinkReturnToRefererView ()

@property (readwrite, strong, nonatomic) UILabel *labelView;
@property (readwrite, strong, nonatomic) UIButton *closeButton;
@property (readwrite, strong, nonatomic) UITapGestureRecognizer *insideTapGestureRecognizer;

@property (readwrite, strong, nonatomic) UINavigationController *attachedToNavController;
@property (readwrite, strong, nonatomic) UIView *viewToMoveWithNavController;

@end

@implementation BFAppLinkReturnToRefererView {
}

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (instancetype)initWithNSURL:(NSURL *)url {
  return [self initWithBFURL:[BFURL URLWithURL:url]];
}

- (instancetype)initWithBFURL:(BFURL *)url {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _url = url;
        _includeStatusBarInSize = YES;

        self.clipsToBounds = YES;
        self.textColor = [UIColor whiteColor];

        [self setRefererDataFromURL:_url];
        [self initViewsIfNeeded];

        // iOS 7 system blue color
        self.backgroundColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];

        _insideTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapInside:)];
        _labelView.userInteractionEnabled = YES;
        [_labelView addGestureRecognizer:_insideTapGestureRecognizer];

        [self sizeToFit];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(statusFrameWillChange:)
                                                     name:UIApplicationWillChangeStatusBarFrameNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(statusFrameDidChange:)
                                                   name:UIApplicationDidChangeStatusBarFrameNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationDidChange:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillChangeStatusBarFrameNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidChangeStatusBarFrameNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:nil];
}

- (void)setRefererDataFromURL:(BFURL *)url {
    NSDictionary *refererData = url.appLinkData[BFRefererAppLink];
    _refererName = refererData[BFRefererName];

    NSString *refererURLString = refererData[BFRefererUrl];
    _refererURL = refererURLString ? [NSURL URLWithString:refererURLString] : nil;
}

- (void)initViewsIfNeeded {
    if (!_labelView && !_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.backgroundColor = [UIColor clearColor];
        _closeButton.userInteractionEnabled = YES;
        _closeButton.clipsToBounds = YES;
        _closeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        [_closeButton addTarget:self action:@selector(closeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:_closeButton];

        _labelView = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelView.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
        _labelView.textColor = [UIColor whiteColor];
        _labelView.backgroundColor = [UIColor clearColor];
        _labelView.textAlignment = UITextAlignmentCenter;
        _labelView.clipsToBounds = YES;
        _labelView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        [self updateLabelText];
        [self addSubview:_labelView];

        [self updateColors];
    }
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect bounds = self.bounds;

    CGSize labelSize = [_labelView sizeThatFits:bounds.size];
    _labelView.preferredMaxLayoutWidth = _labelView.bounds.size.width;
    _labelView.frame = CGRectMake(BFMarginX,
                                  CGRectGetMaxY(bounds) - labelSize.height - BFMarginY,
                                  CGRectGetMaxX(bounds) - BFCloseButtonWidth - 3 * BFMarginX,
                                  labelSize.height);

    _closeButton.frame = CGRectMake(CGRectGetMaxX(bounds) - BFCloseButtonWidth - BFMarginX,
                                    _labelView.center.y - BFCloseButtonHeight / 2.0,
                                    BFCloseButtonWidth,
                                    BFCloseButtonHeight);
}

- (CGSize)sizeThatFits:(CGSize)size {
    if (_closed || !self.hasRefererData) {
        return CGSizeMake(size.width, 0.0);
    }

    CGSize labelSize = [_labelView sizeThatFits:size];
    return CGSizeMake(size.width, labelSize.height + 2 * BFMarginX + self.statusBarHeight);
}

- (CGFloat)statusBarHeight {
    UIApplication *application = [UIApplication sharedApplication];
    float systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];

    BOOL include = (_includeStatusBarInSize && systemVersion >= 7.0) || _attachedToNavController;
    if (include && !application.statusBarHidden) {
        BOOL landscape = UIInterfaceOrientationIsLandscape(application.statusBarOrientation);
        return landscape ? application.statusBarFrame.size.width : application.statusBarFrame.size.height;
    }

    return 0;
}

#pragma mark - Public API

- (void)setIncludeStatusBarInSize:(BOOL)includeStatusBarInSize {
    _includeStatusBarInSize = includeStatusBarInSize;
    [self setNeedsLayout];
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    [self updateColors];
}

- (void)setUrl:(BFURL *)url {
    _url = url;
    _closed = NO;

    [self setRefererDataFromURL:_url];
    [self initViewsIfNeeded];


    [self sizeToFit];
}

- (void)closeAnimated:(BOOL)animated {
    void (^closer)(void) = ^{
        if (_attachedToNavController) {
            CGRect oldFrame = _attachedToNavController.navigationBar.frame;

            _attachedToNavController.navigationBar.frame = CGRectMake(0,
                                                                      self.statusBarHeight,
                                                                      _attachedToNavController.navigationBar.frame.size.width,
                                                                      _attachedToNavController.navigationBar.frame.size.height);

            CGFloat dy = CGRectGetMaxY(_attachedToNavController.navigationBar.frame) - CGRectGetMaxY(oldFrame);


            _viewToMoveWithNavController.frame = CGRectMake(_viewToMoveWithNavController.frame.origin.x,
                                                            _viewToMoveWithNavController.frame.origin.y + dy,
                                                            _viewToMoveWithNavController.frame.size.width,
                                                            _viewToMoveWithNavController.frame.size.height - dy);
        }

        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y,
                                self.frame.size.width,
                                0);
    };

    if (animated) {
        UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
        [UIView animateWithDuration:kBFViewAnimationDuration delay:0.0 options:options animations:^{
            closer();
        } completion:^(BOOL animateOutFinished) {
            _closed = YES;
        }];
    } else {
        closer();
        _closed = YES;
    }
}

- (void)attachToMainWindowAboveNavigationController:(UINavigationController *)navigationController
                                               view:(UIView *)view {
    _attachedToNavController = navigationController;
    _viewToMoveWithNavController = view;

    [self sizeToFit];

    [_attachedToNavController.view addSubview:self];

    if (!_closed) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self moveNavigationBar];
        });
    }
}

- (void)detachFromMainWindow {
    [self closeAnimated:NO];
    [self removeFromSuperview];

    _attachedToNavController = nil;
    _viewToMoveWithNavController = nil;
}

#pragma mark - Private

- (void)updateLabelText {
    _labelView.text = [self localizedLabelForReferer:_refererName];
}

- (void)updateColors {
    UIImage *closeButtonImage = [self drawCloseButtonImageWithColor:_textColor];

    _labelView.textColor = _textColor;
    [_closeButton setBackgroundImage:closeButtonImage forState:UIControlStateNormal];
}

- (UIImage *)drawCloseButtonImageWithColor:(UIColor *)color {

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(BFCloseButtonWidth, BFCloseButtonHeight), NO, 0.0f);

    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetStrokeColorWithColor(context, [color CGColor]);
    CGContextSetFillColorWithColor(context, [color CGColor]);

    CGContextSetLineWidth(context, 1.25f);

    CGFloat inset = 0.5f;

    CGContextMoveToPoint(context, inset, inset);
    CGContextAddLineToPoint(context, BFCloseButtonWidth - inset, BFCloseButtonHeight - inset);
    CGContextStrokePath(context);

    CGContextMoveToPoint(context, BFCloseButtonWidth - inset, inset);
    CGContextAddLineToPoint(context, inset, BFCloseButtonHeight - inset);
    CGContextStrokePath(context);

    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return result;
}

- (NSString *)localizedLabelForReferer:(NSString *)refererName {
    if (!refererName) {
        return nil;
    }

    NSString *format = NSLocalizedString(@"Touch to return to %1$@", @"Format for the string to return to a calling app.");

    return [NSString stringWithFormat:format, refererName];
}

- (BOOL)hasRefererData {
    return _refererName && _refererURL && [[UIApplication sharedApplication] canOpenURL:_refererURL];
}

- (void)closeButtonTapped:(id)sender {
    [self closeAnimated:YES];
}

- (void)onTapInside:(UIGestureRecognizer*)sender {
    [self openRefererUrl];
    [self closeAnimated:NO];
}

- (void)openRefererUrl {
    if (_refererURL) {
        if ([_delegate respondsToSelector:@selector(returnToRefererView:willOpenURL:)]) {
            [_delegate returnToRefererView:self willOpenURL:_refererURL];
        }

        BOOL success = [[UIApplication sharedApplication] openURL:_refererURL];

        if ([_delegate respondsToSelector:@selector(returnToRefererView:didOpenURL:success:)]) {
            [_delegate returnToRefererView:self didOpenURL:_refererURL success:success];
        }
    }
}

- (void)moveNavigationBar {
    CGRect oldFrame = _attachedToNavController.navigationBar.frame;

    _attachedToNavController.navigationBar.frame = CGRectMake(0,
                                                              self.frame.size.height,
                                                              _attachedToNavController.navigationBar.frame.size.width,
                                                              _attachedToNavController.navigationBar.frame.size.height);

    CGFloat dy = CGRectGetMaxY(_attachedToNavController.navigationBar.frame) - CGRectGetMaxY(oldFrame);
    _viewToMoveWithNavController.frame = CGRectMake(_viewToMoveWithNavController.frame.origin.x,
                                                    _viewToMoveWithNavController.frame.origin.y + dy,
                                                    _viewToMoveWithNavController.frame.size.width,
                                                    _viewToMoveWithNavController.frame.size.height - dy);
}

- (void)statusFrameWillChange:(NSNotification *)notification {
    NSValue* rectValue = [[notification userInfo] valueForKey:UIApplicationStatusBarFrameUserInfoKey];
    CGRect newFrame;
    [rectValue getValue:&newFrame];

    if (_attachedToNavController && !_closed) {
        if (newFrame.size.height == 40) {
            UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
            [UIView animateWithDuration:kBFViewAnimationDuration delay:0.0 options:options animations:^{
                self.frame = CGRectMake(0.0, 0.0, self.frame.size.width, 0.0);
            } completion:nil];
        }
    }
}

- (void)statusFrameDidChange:(NSNotification *)notification {
    NSValue* rectValue = [[notification userInfo] valueForKey:UIApplicationStatusBarFrameUserInfoKey];
    CGRect newFrame;
    [rectValue getValue:&newFrame];

    if (_attachedToNavController && !_closed) {
        if (newFrame.size.height == 40) {
            UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
            [UIView animateWithDuration:kBFViewAnimationDuration delay:0.0 options:options animations:^{
                [self sizeToFit];
                [self moveNavigationBar];
            } completion:nil];
        }
    }
}

- (void)orientationDidChange:(NSNotificationCenter *)notification {
    if (_attachedToNavController && !_closed && self.frame.size.height > 0) {
      dispatch_async(dispatch_get_main_queue(), ^{
        [self moveNavigationBar];
      });
    }
}

#pragma mark - Class methods

+ (instancetype)viewWithNSURL:(NSURL *)url {
    return [[BFAppLinkReturnToRefererView alloc] initWithNSURL:url];
}

+ (instancetype)viewWithBFURL:(BFURL *)url {
    return [[BFAppLinkReturnToRefererView alloc] initWithBFURL:url];
}

@end
