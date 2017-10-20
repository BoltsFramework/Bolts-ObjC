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

- (void)testCancel {
    BFCancellationTokenSource *cts = [BFCancellationTokenSource cancellationTokenSource];

    XCTAssertFalse(cts.cancellationRequested, @"Source should not be cancelled");
    XCTAssertFalse(cts.token.cancellationRequested, @"Token should not be cancelled");

    [cts cancel];

    XCTAssertTrue(cts.cancellationRequested, @"Source should be cancelled");
    XCTAssertTrue(cts.token.cancellationRequested, @"Token should be cancelled");
}

- (void)testCancelMultipleTimes {
    BFCancellationTokenSource *cts = [BFCancellationTokenSource cancellationTokenSource];
    XCTAssertFalse(cts.cancellationRequested);
    XCTAssertFalse(cts.token.cancellationRequested);

    [cts cancel];
    XCTAssertTrue(cts.cancellationRequested);
    XCTAssertTrue(cts.token.cancellationRequested);

    [cts cancel];
    XCTAssertTrue(cts.cancellationRequested);
    XCTAssertTrue(cts.token.cancellationRequested);
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

- (void)testCancellationAfterDelayValidation {
    BFCancellationTokenSource *cts = [BFCancellationTokenSource cancellationTokenSource];

    XCTAssertFalse(cts.cancellationRequested);
    XCTAssertFalse(cts.token.cancellationRequested);

    XCTAssertThrowsSpecificNamed([cts cancelAfterDelay:-2], NSException, NSInvalidArgumentException);
}

- (void)testCancellationAfterZeroDelay {
    BFCancellationTokenSource *cts = [BFCancellationTokenSource cancellationTokenSource];

    XCTAssertFalse(cts.cancellationRequested);
    XCTAssertFalse(cts.token.cancellationRequested);

    [cts cancelAfterDelay:0];

    XCTAssertTrue(cts.cancellationRequested);
    XCTAssertTrue(cts.token.cancellationRequested);
}

- (void)testCancellationAfterDelayOnCancelled {
    BFCancellationTokenSource *cts = [BFCancellationTokenSource cancellationTokenSource];
    [cts cancel];
    XCTAssertTrue(cts.cancellationRequested);
    XCTAssertTrue(cts.token.cancellationRequested);

    [cts cancelAfterDelay:1];

    XCTAssertTrue(cts.cancellationRequested);
    XCTAssertTrue(cts.token.cancellationRequested);
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

- (void)testDisposeMultipleTimes {
    BFCancellationTokenSource *cts = [BFCancellationTokenSource cancellationTokenSource];
    [cts dispose];
    XCTAssertNoThrow([cts dispose]);
}

- (void)testDisposeRegistration {
    BFCancellationTokenSource *cts = [BFCancellationTokenSource cancellationTokenSource];
    BFCancellationTokenRegistration *registration = [cts.token registerCancellationObserverWithBlock:^{
        XCTFail();
    }];
    XCTAssertNoThrow([registration dispose]);

    [cts cancel];
}

- (void)testDisposeRegistrationMultipleTimes {
    BFCancellationTokenSource *cts = [BFCancellationTokenSource cancellationTokenSource];
    BFCancellationTokenRegistration *registration = [cts.token registerCancellationObserverWithBlock:^{
        XCTFail();
    }];
    XCTAssertNoThrow([registration dispose]);
    XCTAssertNoThrow([registration dispose]);

    [cts cancel];
}

- (void)testDisposeRegistrationAfterCancellationToken {
    BFCancellationTokenSource *cts = [BFCancellationTokenSource cancellationTokenSource];
    BFCancellationTokenRegistration *registration = [cts.token registerCancellationObserverWithBlock:^{ }];

    [registration dispose];
    [cts dispose];
}

- (void)testDisposeRegistrationBeforeCancellationToken {
    BFCancellationTokenSource *cts = [BFCancellationTokenSource cancellationTokenSource];
    BFCancellationTokenRegistration *registration = [cts.token registerCancellationObserverWithBlock:^{ }];

    [cts dispose];
    XCTAssertNoThrow([registration dispose]);
}

@end
