/*
 *  Copyright (c) 2014, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

@import XCTest;

#import <Bolts/Bolts.h>

@interface ExecutorTests : XCTestCase

@end

@implementation ExecutorTests

- (void)testExecuteImmediately {
    __block BFTask *task = [BFTask taskWithResult:nil];

    XCTestExpectation *expectation = [self expectationWithDescription:@"test immediate executor"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        task = [task continueWithExecutor:[BFExecutor immediateExecutor] withBlock:^id(BFTask *_) {
            return nil;
        }];
        XCTAssertTrue(task.completed);
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

- (void)testExecuteOnDispatchQueue {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0L);
    BFExecutor *queueExecutor = [BFExecutor executorWithDispatchQueue:queue];

    BFTask *task = [BFTask taskWithResult:nil];
    task = [task continueWithExecutor:queueExecutor withBlock:^id(BFTask *_) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        XCTAssertEqual(queue, dispatch_get_current_queue());
#pragma clang diagnostic pop
        return nil;
    }];
    [task waitUntilFinished];
}

- (void)testExecuteOnOperationQueue {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    BFExecutor *queueExecutor = [BFExecutor executorWithOperationQueue:queue];

    BFTask *task = [BFTask taskWithResult:nil];
    task = [task continueWithExecutor:queueExecutor withBlock:^id(BFTask *_) {
        XCTAssertEqual(queue, [NSOperationQueue currentQueue]);
        return nil;
    }];
    [task waitUntilFinished];
}

- (void)testMainThreadExecutor {
    BFExecutor *executor = [BFExecutor mainThreadExecutor];

    XCTestExpectation *immediateExpectation = [self expectationWithDescription:@"test main thread executor on main thread"];
    [executor execute:^{
        XCTAssertTrue([NSThread isMainThread]);
        [immediateExpectation fulfill];
    }];

    // Behaviour is different when running on main thread (runs immediately) vs running on the background queue.
    XCTestExpectation *backgroundExpectation = [self expectationWithDescription:@"test main thread executor on background thread"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [executor execute:^{
            XCTAssertTrue([NSThread isMainThread]);
            [backgroundExpectation fulfill];
        }];
    });

    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

@end
