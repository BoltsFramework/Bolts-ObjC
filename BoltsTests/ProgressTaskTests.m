/*
 *  Copyright (c) 2014, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import <XCTest/XCTest.h>

#import "Bolts.h"

@interface ProgressTaskTests : XCTestCase
@end

@implementation ProgressTaskTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (BFTask*)_progressTask
{
    BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
    
    for (int i = 1; i <= 10; i++) {
        double delayInSeconds = 0.2 * i;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            if (i < 10) {
                tcs.progress = [NSString stringWithFormat:@"%d%%",i*10]; //@(i/10.0);
            }
            else {
                tcs.result = @"Done";
            }
        });
    }
    return tcs.task;
}

- (void)testProgressTask {
    [[[self _progressTask] continueWithBlock:^id(BFTask *task) {
        
        NSLog(@"progress = %@",task.progress);
        NSLog(@"result = %@",task.result);
        NSLog(@"\n");
        
        XCTAssertTrue(task.progress || task.result);
        
        return nil;
        
    }] waitUntilFinished];
}

- (void)testSuccessProgressTask {
    [[[self _progressTask] continueWithSuccessBlock:^id(BFTask *task) {
        
        NSLog(@"progress = %@",task.progress);
        NSLog(@"result = %@",task.result);
        NSLog(@"\n");
        
        XCTAssertNil(task.progress);
        XCTAssertEqualObjects(task.result, @"Done");
        
        return nil;
        
    }] waitUntilFinished];
}

@end
