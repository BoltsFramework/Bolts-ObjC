/*
 *  Copyright (c) 2014, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import <Foundation/Foundation.h>

/*! The name of the notification posted by BFMeasurementEvent */
FOUNDATION_EXPORT NSString *const BFMeasurementEventNotificationName;

/*! Defines keys in the userInfo object for the notification named BFMeasurementEventNotificationName */
FOUNDATION_EXPORT NSString *const BFMeasurementEventNameKey;
FOUNDATION_EXPORT NSString *const BFMeasurementEventArgsKey;

/*! 
 * Provides methods for posting notifications from the Bolts framework
 */
@interface BFMeasurementEvent : NSObject

+ (void) postNotificationForEventName:(NSString *)name args:(NSDictionary *)args;

@end
