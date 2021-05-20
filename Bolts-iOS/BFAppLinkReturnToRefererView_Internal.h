/*
 *  Copyright (c) 2014, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#if TARGET_OS_IOS || TARGET_OS_SIMULATOR || TARGET_OS_MACCATALYST

#import "BFAppLinkReturnToRefererView.h"

@interface BFAppLinkReturnToRefererView (Internal)

- (CGFloat)statusBarHeight;

@end

#endif
