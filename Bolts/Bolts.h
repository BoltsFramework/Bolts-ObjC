/*
 *  Copyright (c) 2014, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import "BFCancellationToken.h"
#import "BFCancellationTokenRegistration.h"
#import "BFCancellationTokenSource.h"
#import "BFExecutor.h"
#import "BFGeneric.h"
#import "BFTask.h"
#import "BFTaskCompletionSource.h"

#if TARGET_OS_IPHONE && !TARGET_OS_WATCH && !TARGET_OS_TV

#if SWIFT_PACKAGE

#import "../Bolts-iOS/BFAppLink.h"
#import "../Bolts-iOS/BFAppLinkNavigation.h"
#import "../Bolts-iOS/BFAppLinkResolving.h"
#import "../Bolts-iOS/BFAppLinkReturnToRefererController.h"
#import "../Bolts-iOS/BFAppLinkReturnToRefererView.h"
#import "../Bolts-iOS/BFAppLinkTarget.h"
#import "../Bolts-iOS/BFMeasurementEvent.h"
#import "../Bolts-iOS/BFURL.h"
#import "../Bolts-iOS/BFWebViewAppLinkResolver.h"

#else

#import <Bolts/BFAppLink.h>
#import <Bolts/BFAppLinkNavigation.h>
#import <Bolts/BFAppLinkResolving.h>
#import <Bolts/BFAppLinkReturnToRefererController.h>
#import <Bolts/BFAppLinkReturnToRefererView.h>
#import <Bolts/BFAppLinkTarget.h>
#import <Bolts/BFMeasurementEvent.h>
#import <Bolts/BFURL.h>
#import <Bolts/BFWebViewAppLinkResolver.h>

#endif

#endif


NS_ASSUME_NONNULL_BEGIN

/**
 A string containing the version of the Bolts Framework used by the current application.
 */
extern NSString *const BoltsFrameworkVersionString;

NS_ASSUME_NONNULL_END
