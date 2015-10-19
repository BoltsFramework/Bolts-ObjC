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

@interface CancellationTests : XCTestCase
@end

@implementation CancellationTests

- (void)testCancellation {
    BFCancellationTokenSource *cts = [BFCancellationTokenSource cancellationTokenSource];

    XCTAssertFalse(cts.cancellationRequested, @"Source should not be cancelled");
    XCTAssertFalse(cts.token.cancellationRequested, @"Token should not be cancelled");

    [cts cancel];

    XCTAssertTrue(cts.cancellationRequested, @"Source should be cancelled");
    XCTAssertTrue(cts.token.cancellationRequested, @"Token should be cancelled");
}

- (void)testCancellationBlock {
    __block BOOL cancelled = NO;

    BFCancellationTokenSource *cts = [BFCancellationTokenSource cancellationTokenSource];
    [cts.token registerCancellationObserverWithBlock:^{
        cancelled = YES;
    }];

    XCTAssertFalse(cts.cancellationRequested, @"Source should not be cancelled");
    XCTAssertFalse(cts.token.cancellationRequested, @"Token should not be cancelled");

    [cts cancel];

    XCTAssertTrue(cancelled, @"Source should be cancelled");
}

- (void)testCancellationAfterDelay {
    BFCancellationTokenSource *cts = [BFCancellationTokenSource cancellationTokenSource];

    XCTAssertFalse(cts.cancellationRequested, @"Source should not be cancelled");
    XCTAssertFalse(cts.token.cancellationRequested, @"Token should not be cancelled");

    [cts cancelAfterDelay:200];
    XCTAssertFalse(cts.cancellationRequested, @"Source should be cancelled");
    XCTAssertFalse(cts.token.cancellationRequested, @"Token should be cancelled");

    // Spin the run loop for half a second, since `delay` is in milliseconds, not seconds.
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];

    XCTAssertTrue(cts.cancellationRequested, @"Source should be cancelled");
    XCTAssertTrue(cts.token.cancellationRequested, @"Token should be cancelled");
}

- (void)testDispose {
    BFCancellationTokenSource *cts = [BFCancellationTokenSource cancellationTokenSource];
    [cts dispose];
    XCTAssertThrowsSpecificNamed([cts cancel], NSException, NSInternalInconsistencyException);
    XCTAssertThrowsSpecificNamed(cts.cancellationRequested, NSException, NSInternalInconsistencyException);
    XCTAssertThrowsSpecificNamed(cts.token.cancellationRequested, NSException, NSInternalInconsistencyException);

    cts = [BFCancellationTokenSource cancellationTokenSource];
    [cts cancel];
    XCTAssertTrue(cts.cancellationRequested, @"Source should be cancelled");
    XCTAssertTrue(cts.token.cancellationRequested, @"Token should be cancelled");

    [cts dispose];
    XCTAssertThrowsSpecificNamed(cts.cancellationRequested, NSException, NSInternalInconsistencyException);
    XCTAssertThrowsSpecificNamed(cts.token.cancellationRequested, NSException, NSInternalInconsistencyException);
}

@end
