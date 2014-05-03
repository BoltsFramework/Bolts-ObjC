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

#import "BFAppLink.h"
#import "BFAppLinkTarget.h"

static const CGFloat BFMarginX = 8.5f;
static const CGFloat BFMarginY = 8.5f;

static NSString *const BFRefererAppLink = @"referer_app_link";
static NSString *const BFRefererAppName = @"app_name";
static NSString *const BFRefererUrl = @"url";
static const CGFloat BFCloseButtonWidth = 12.0;
static const CGFloat BFCloseButtonHeight = 12.0;

@interface BFAppLinkReturnToRefererView ()

@property (readwrite, strong, nonatomic) UILabel *labelView;
@property (readwrite, strong, nonatomic) UIButton *closeButton;
@property (readwrite, strong, nonatomic) UITapGestureRecognizer *insideTapGestureRecognizer;
@property (readwrite, strong, nonatomic) UIView *viewToMoveWithNavController;

@end

@implementation BFAppLinkReturnToRefererView

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
        [self sizeToFit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
  // Initialization code
  _includeStatusBarInSize = BFIncludeStatusBarInSizeIOS7AndLater;

  // iOS 7 system blue color
  self.backgroundColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
  self.textColor = [UIColor whiteColor];
  self.clipsToBounds = YES;

  [self initViews];
}

- (void)initViews {
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
#ifdef __IPHONE_6_0
        _labelView.textAlignment = NSTextAlignmentCenter;
#else
        _labelView.textAlignment = UITextAlignmentCenter;
#endif
        _labelView.clipsToBounds = YES;
        _labelView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        [self updateLabelText];
        [self addSubview:_labelView];


        _insideTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapInside:)];
        _labelView.userInteractionEnabled = YES;
        [_labelView addGestureRecognizer:_insideTapGestureRecognizer];

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

    BOOL include = (_includeStatusBarInSize == BFIncludeStatusBarInSizeIOS7AndLater && systemVersion >= 7.0) ||
        _includeStatusBarInSize == BFIncludeStatusBarInSizeAlways;
    if (include && !application.statusBarHidden) {
        BOOL landscape = UIInterfaceOrientationIsLandscape(application.statusBarOrientation);
        return landscape ? application.statusBarFrame.size.width : application.statusBarFrame.size.height;
    }

    return 0;
}

#pragma mark - Public API

- (void)setIncludeStatusBarInSize:(BFIncludeStatusBarInSize)includeStatusBarInSize {
    _includeStatusBarInSize = includeStatusBarInSize;
    [self setNeedsLayout];
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    [self updateColors];
}

- (void)setRefererAppLink:(BFAppLink *)refererAppLink {
  _refererAppLink = refererAppLink;
  [self updateLabelText];
}

#pragma mark - Private

- (void)updateLabelText {
    NSString *appName = (_refererAppLink && _refererAppLink.targets[0]) ? [_refererAppLink.targets[0] appName] : nil;
    _labelView.text = [self localizedLabelForReferer:appName];
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
    return _refererAppLink && _refererAppLink.targets[0];
}

- (void)closeButtonTapped:(id)sender {
    [_delegate returnToRefererViewDidTapInsideCloseButton:self];
}

- (void)onTapInside:(UIGestureRecognizer*)sender {
    [_delegate returnToRefererViewDidTapInsideLink:self link:_refererAppLink];
}

@end
