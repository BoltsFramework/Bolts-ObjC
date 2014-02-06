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

@interface DotSyntaxedTaskTests : XCTestCase
@end

@implementation DotSyntaxedTaskTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testPassOnError {
    NSError *originalError = [NSError errorWithDomain:@"Bolts" code:30 userInfo:nil];
    [BFTask.taskWithError(originalError).continueWithSuccessBlock(^id(BFTask *task) {
        XCTFail(@"This callback should be skipped.");
        return nil;
    }).continueWithSuccessBlock(^id(BFTask *task) {
        XCTFail(@"This callback should be skipped.");
        return nil;
    }).continueWithBlock(^id(BFTask *task) {
        XCTAssertNotNil(task.error);
        XCTAssertEqual((NSInteger)30, task.error.code);
        NSError *newError = [NSError errorWithDomain:@"Bolts" code:31 userInfo:nil];
        return BFTask.taskWithError(newError);
    }).continueWithSuccessBlock(^id(BFTask *task) {
        XCTFail(@"This callback should be skipped.");
        return nil;
    }).continueWithBlock(^id(BFTask *task) {
        XCTAssertNotNil(task.error);
        XCTAssertEqual((NSInteger)31, task.error.code);
        return BFTask.taskWithResult(@"okay");
    }).continueWithSuccessBlock(^id(BFTask *task) {
        XCTAssertEqualObjects(@"okay", task.result);
        return nil;
    }) waitUntilFinished];
}

- (void)testExecuteImmediately {
    XCTAssertTrue([NSThread isMainThread]);
    BFTask *task = [BFTask taskWithResult:nil];
    task = task.continueWithExecutor([BFExecutor immediateExecutor]).withBlock(^id(BFTask *task) {
        XCTAssertTrue([NSThread isMainThread]);
        return nil;
    });
    XCTAssertTrue(task.isCompleted);
}

@end
