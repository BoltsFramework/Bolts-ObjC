/*
 *  Copyright (c) 2014, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import "BoltsVersion.h"
#import "BFCancellationToken.h"
#import "BFCancellationTokenRegistration.h"
#import "BFCancellationTokenSource.h"
#import "BFDefines.h"
#import "BFExecutor.h"
#import "BFTask.h"
#import "BFTaskCompletionSource.h"

#if __has_include(<Bolts/BFAppLink.h>) && TARGET_OS_IPHONE && !TARGET_OS_WATCH && !TARGET_OS_TV
#import "BFAppLink.h"
#import "BFAppLinkNavigation.h"
#import "BFAppLinkResolving.h"
#import "BFAppLinkReturnToRefererController.h"
#import "BFAppLinkReturnToRefererView.h"
#import "BFAppLinkTarget.h"
#import "BFMeasurementEvent.h"
#import "BFURL.h"
#import "BFWebViewAppLinkResolver.h"
#endif

/*! @abstract 80175001: There were multiple errors. */
extern NSInteger const kBFMultipleErrorsError;

@interface Bolts : NSObject

/*!
 Returns the version of the Bolts Framework as an NSString.
 @returns The NSString representation of the current version.
 */
+ (NSString *)version;

@end
