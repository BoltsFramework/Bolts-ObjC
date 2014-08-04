/*
 *  Copyright (c) 2014, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import "BFMeasurementEvent.h"

NSString *const BFMeasurementEventNotificationName = @"com.parse.bolts.measurement_event";

NSString *const BFMeasurementEventNameKey = @"event_name";
NSString *const BFMeasurementEventArgsKey = @"event_args";

__attribute__ ((noinline)) void warnOnMissingEventName() {
    NSLog(@"Warning: Missing event name when logging bolts measurement event. \n"
          " Ignoring this event in logging.");
}

@implementation BFMeasurementEvent
{
    NSString *_name;
    NSDictionary *_args;
}

- (void) postNotification{
    if (!_name) {
        warnOnMissingEventName();
        return;
    }
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    NSDictionary *userInfo = @{BFMeasurementEventNameKey: _name,
                               BFMeasurementEventArgsKey: _args};
    
    [center postNotificationName:BFMeasurementEventNotificationName
                          object:self
                        userInfo:userInfo];
}

- (BFMeasurementEvent *) initEventWithName:(NSString *)name args:(NSDictionary *)args {
    if ((self = [super init])) {;
        _name = name;
        _args = args ? args : @{};
    }
    return self;
}

+ (void) postNotificationForEventName:(NSString *)name args:(NSDictionary *)args {
    [[[BFMeasurementEvent alloc] initEventWithName:name args:args] postNotification];
}

@end
