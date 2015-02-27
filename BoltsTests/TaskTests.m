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

@interface TaskTests : XCTestCase
@end

@implementation TaskTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testBasicOnSuccess {
    [[[BFTask taskWithResult:@"foo"] continueWithSuccessBlock:^id(BFTask *task) {
        XCTAssertEqualObjects(@"foo", task.result);
        return nil;
    }] waitUntilFinished];
}

- (void)testBasicContinueWithError {
    NSError *originalError = [NSError errorWithDomain:@"Bolts" code:22 userInfo:nil];
    [[[BFTask taskWithError:originalError] continueWithBlock:^id(BFTask *task) {
        XCTAssertNotNil(task.error, @"Task should have failed.");
        XCTAssertEqual((NSInteger)22, task.error.code);
        return nil;
    }] waitUntilFinished];
}

- (void)testBasicContinueWithException {
    NSString *message = @"This is expected.";
    [[[[BFTask taskWithResult:nil] continueWithBlock:^id(BFTask *task) {
        [NSException raise:NSInternalInconsistencyException format:message];
        return nil;
    }] continueWithBlock:^id(BFTask *task) {
        XCTAssertNotNil(task.exception, @"Task should have failed.");
        XCTAssertEqualObjects(message, task.exception.description);
        return nil;
    }] waitUntilFinished];
}

- (void)testFinishLaterWithSuccess {
    BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
    BFTask *task = [tcs.task continueWithBlock:^id(BFTask *task) {
        XCTAssertEqualObjects(@"bar", task.result);
        return nil;
    }];
    [[BFTask taskWithDelay:0] continueWithBlock:^id(BFTask *task) {
        tcs.result = @"bar";
        return nil;
    }];
    [task waitUntilFinished];
}

- (void)testFinishLaterWithError {
    BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
    BFTask *task = [tcs.task continueWithBlock:^id(BFTask *task) {
        XCTAssertNotNil(task.error);
        XCTAssertEqual((NSInteger)23, task.error.code);
        return nil;
    }];
    [[BFTask taskWithDelay:0] continueWithBlock:^id(BFTask *task) {
        tcs.error = [NSError errorWithDomain:@"Bolts" code:23 userInfo:nil];
        return nil;
    }];
    [task waitUntilFinished];
}

- (void)testFinishLaterWithException {
    NSString *message = @"This is expected.";
    BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
    BFTask *task = [tcs.task continueWithBlock:^id(BFTask *task) {
        XCTAssertNotNil(task.exception, @"Task should have failed.");
        XCTAssertEqualObjects(message, task.exception.description);
        return nil;
    }];
    [tcs setException:[NSException exceptionWithName:NSInternalInconsistencyException
                                              reason:message
                                            userInfo:nil]];
    [task waitUntilFinished];
}

- (void)testTransformConstantToConstant {
    BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
    BFTask *task = [[tcs.task continueWithBlock:^id(BFTask *task) {
        XCTAssertEqualObjects(@"foo", task.result);
        return @"bar";
    }] continueWithBlock:^id(BFTask *task) {
        XCTAssertEqualObjects(@"bar", task.result);
        return nil;
    }];
    [[BFTask taskWithDelay:0] continueWithBlock:^id(BFTask *task) {
        tcs.result = @"foo";
        return nil;
    }];
    [task waitUntilFinished];
}

- (void)testTransformErrorToConstant {
    BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
    BFTask *task = [[tcs.task continueWithBlock:^id(BFTask *task) {
        XCTAssertNotNil(task.error);
        XCTAssertEqual((NSInteger)23, task.error.code);
        return @"bar";
    }] continueWithBlock:^id(BFTask *task) {
        XCTAssertEqualObjects(@"bar", task.result);
        return nil;
    }];
    [[BFTask taskWithDelay:0] continueWithBlock:^id(BFTask *task) {
        tcs.error = [NSError errorWithDomain:@"Bolts" code:23 userInfo:nil];
        return nil;
    }];
    [task waitUntilFinished];
}

- (void)testReturnSuccessfulTaskFromContinuation {
    BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
    BFTask *task = [[tcs.task continueWithBlock:^id(BFTask *task) {
        XCTAssertEqualObjects(@"foo", task.result);
        return [BFTask taskWithResult:@"bar"];
    }] continueWithBlock:^id(BFTask *task) {
        XCTAssertEqualObjects(@"bar", task.result);
        return nil;
    }];
    [[BFTask taskWithDelay:0] continueWithBlock:^id(BFTask *task) {
        tcs.result = @"foo";
        return nil;
    }];
    [task waitUntilFinished];
}

- (void)testReturnSuccessfulTaskFromContinuationAfterError {
    BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
    BFTask *task = [[tcs.task continueWithBlock:^id(BFTask *task) {
        XCTAssertNotNil(task.error);
        XCTAssertEqual((NSInteger)23, task.error.code);
        return [BFTask taskWithResult:@"bar"];
    }] continueWithBlock:^id(BFTask *task) {
        XCTAssertEqualObjects(@"bar", task.result);
        return nil;
    }];
    [[BFTask taskWithDelay:0] continueWithBlock:^id(BFTask *task) {
        tcs.error = [NSError errorWithDomain:@"Bolts" code:23 userInfo:nil];
        return nil;
    }];
    [task waitUntilFinished];
}

- (void)testReturnErrorTaskFromContinuation {
    BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
    BFTask *task = [[tcs.task continueWithBlock:^id(BFTask *task) {
        XCTAssertEqualObjects(@"foo", task.result);
        NSError *originalError = [NSError errorWithDomain:@"Bolts" code:24 userInfo:nil];
        return [BFTask taskWithError:originalError];
    }] continueWithBlock:^id(BFTask *task) {
        XCTAssertNotNil(task.error);
        XCTAssertEqual((NSInteger)24, task.error.code);
        return nil;
    }];
    [[BFTask taskWithDelay:0] continueWithBlock:^id(BFTask *task) {
        tcs.result = @"foo";
        return nil;
    }];
    [task waitUntilFinished];
}

- (void)testReturnErrorTaskFromContinuationAfterError {
    BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
    BFTask *task = [[tcs.task continueWithBlock:^id(BFTask *task) {
        XCTAssertNotNil(task.error);
        XCTAssertEqual((NSInteger)23, task.error.code);
        NSError *originalError = [NSError errorWithDomain:@"Bolts" code:24 userInfo:nil];
        return [BFTask taskWithError:originalError];
    }] continueWithBlock:^id(BFTask *task) {
        XCTAssertNotNil(task.error);
        XCTAssertEqual((NSInteger)24, task.error.code);
        return nil;
    }];
    [[BFTask taskWithDelay:0] continueWithBlock:^id(BFTask *task) {
        tcs.error = [NSError errorWithDomain:@"Bolts" code:23 userInfo:nil];
        return nil;
    }];
    [task waitUntilFinished];
}

- (void)testPassOnError {
    NSError *originalError = [NSError errorWithDomain:@"Bolts" code:30 userInfo:nil];
    [[[[[[[[BFTask taskWithError:originalError] continueWithSuccessBlock:^id(BFTask *task) {
        XCTFail(@"This callback should be skipped.");
        return nil;
    }] continueWithSuccessBlock:^id(BFTask *task) {
        XCTFail(@"This callback should be skipped.");
        return nil;
    }] continueWithBlock:^id(BFTask *task) {
        XCTAssertNotNil(task.error);
        XCTAssertEqual((NSInteger)30, task.error.code);
        NSError *newError = [NSError errorWithDomain:@"Bolts" code:31 userInfo:nil];
        return [BFTask taskWithError:newError];
    }] continueWithSuccessBlock:^id(BFTask *task) {
        XCTFail(@"This callback should be skipped.");
        return nil;
    }] continueWithBlock:^id(BFTask *task) {
        XCTAssertNotNil(task.error);
        XCTAssertEqual((NSInteger)31, task.error.code);
        return [BFTask taskWithResult:@"okay"];
    }] continueWithSuccessBlock:^id(BFTask *task) {
        XCTAssertEqualObjects(@"okay", task.result);
        return nil;
    }] waitUntilFinished];
}

- (void)testCancellation {
    BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
    BFTask *task = [[BFTask taskWithDelay:100] continueWithBlock:^id(BFTask *task) {
        return tcs.task;
    }];

    [tcs cancel];
    [task waitUntilFinished];

    XCTAssertTrue(task.isCancelled);
}

- (void)testTaskForCompletionOfAllTasksSuccess {
    NSMutableArray *tasks = [NSMutableArray array];

    const int kTaskCount = 20;
    for (int i = 0; i < kTaskCount; ++i) {
        double sleepTimeInMs = rand() % 100;
        [tasks addObject:[[BFTask taskWithDelay:sleepTimeInMs] continueWithBlock:^id(BFTask *task) {
            return @(i);
        }]];
    }

    [[[BFTask taskForCompletionOfAllTasks:tasks] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error);
        XCTAssertNil(task.exception);
        XCTAssertFalse(task.isCancelled);

        for (int i = 0; i < kTaskCount; ++i) {
            XCTAssertEqual(i, [((BFTask *)[tasks objectAtIndex:i]).result intValue]);
        }
        return nil;
    }] waitUntilFinished];
}

- (void)testTaskForCompletionOfAllTasksOneException {
    NSMutableArray *tasks = [NSMutableArray array];

    const int kTaskCount = 20;
    for (int i = 0; i < kTaskCount; ++i) {
        double sleepTimeInMs = rand() % 100;
        [tasks addObject:[[BFTask taskWithDelay:sleepTimeInMs] continueWithBlock:^id(BFTask *task) {
            if (i == 10) {
                [NSException raise:@"TestException" format:@"This exception is expected."];
            }
            return @(i);
        }]];
    }

    [[[BFTask taskForCompletionOfAllTasks:tasks] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error);
        XCTAssertNotNil(task.exception);
        XCTAssertFalse(task.isCancelled);

        XCTAssertEqualObjects(@"TestException", task.exception.name);

        for (int i = 0; i < kTaskCount; ++i) {
            if (i == 10) {
                XCTAssertNotNil(((BFTask *)[tasks objectAtIndex:i]).exception);
            } else {
                XCTAssertEqual(i, [((BFTask *)[tasks objectAtIndex:i]).result intValue]);
            }
        }
        return nil;
    }] waitUntilFinished];
}

- (void)testTaskForCompletionOfAllTasksTwoExceptions {
    NSMutableArray *tasks = [NSMutableArray array];

    const int kTaskCount = 20;
    for (int i = 0; i < kTaskCount; ++i) {
        double sleepTimeInMs = rand() % 100;
        [tasks addObject:[[BFTask taskWithDelay:sleepTimeInMs] continueWithBlock:^id(BFTask *task) {
            if (i == 10 || i == 11) {
                [NSException raise:@"TestException" format:@"This exception is expected."];
            }
            return @(i);
        }]];
    }

    [[[BFTask taskForCompletionOfAllTasks:tasks] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error);
        XCTAssertNotNil(task.exception);
        XCTAssertFalse(task.isCancelled);

        XCTAssertEqualObjects(@"BFMultipleExceptionsException", task.exception.name);

        NSArray *exceptions = [task.exception.userInfo objectForKey:@"exceptions"];
        XCTAssertEqual(2, (int)exceptions.count);
        XCTAssertEqualObjects(@"TestException", [[exceptions objectAtIndex:0] name]);
        XCTAssertEqualObjects(@"TestException", [[exceptions objectAtIndex:1] name]);

        for (int i = 0; i < kTaskCount; ++i) {
            if (i == 10 || i == 11) {
                XCTAssertNotNil(((BFTask *)[tasks objectAtIndex:i]).exception);
            } else {
                XCTAssertEqual(i, [((BFTask *)[tasks objectAtIndex:i]).result intValue]);
            }
        }
        return nil;
    }] waitUntilFinished];
}

- (void)testTaskForCompletionOfAllTasksOneError {
    NSMutableArray *tasks = [NSMutableArray array];

    const int kTaskCount = 20;
    for (int i = 0; i < kTaskCount; ++i) {
        double sleepTimeInMs = rand() % 100;
        [tasks addObject:[[BFTask taskWithDelay:sleepTimeInMs] continueWithBlock:^id(BFTask *task) {
            if (i == 10) {
                return [BFTask taskWithError:[NSError errorWithDomain:@"BoltsTests"
                                                                 code:35
                                                             userInfo:nil]];
            }
            return @(i);
        }]];
    }

    [[[BFTask taskForCompletionOfAllTasks:tasks] continueWithBlock:^id(BFTask *task) {
        XCTAssertNotNil(task.error);
        XCTAssertNil(task.exception);
        XCTAssertFalse(task.isCancelled);

        XCTAssertEqualObjects(@"BoltsTests", task.error.domain);
        XCTAssertEqual(35, (int)task.error.code);

        for (int i = 0; i < kTaskCount; ++i) {
            if (i == 10) {
                XCTAssertNotNil(((BFTask *)[tasks objectAtIndex:i]).error);
            } else {
                XCTAssertEqual(i, [((BFTask *)[tasks objectAtIndex:i]).result intValue]);
            }
        }
        return nil;
    }] waitUntilFinished];
}

- (void)testTaskForCompletionOfAllTasksTwoErrors {
    NSMutableArray *tasks = [NSMutableArray array];

    const int kTaskCount = 20;
    for (int i = 0; i < kTaskCount; ++i) {
        double sleepTimeInMs = rand() % 100;
        [tasks addObject:[[BFTask taskWithDelay:sleepTimeInMs] continueWithBlock:^id(BFTask *task) {
            if (i == 10 || i == 11) {
                return [BFTask taskWithError:[NSError errorWithDomain:@"BoltsTests"
                                                                 code:35
                                                             userInfo:nil]];
            }
            return @(i);
        }]];
    }

    [[[BFTask taskForCompletionOfAllTasks:tasks] continueWithBlock:^id(BFTask *task) {
        XCTAssertNotNil(task.error);
        XCTAssertNil(task.exception);
        XCTAssertFalse(task.isCancelled);

        XCTAssertEqualObjects(@"bolts", task.error.domain);
        XCTAssertEqual(kBFMultipleErrorsError, task.error.code);

        NSArray *errors = [task.error.userInfo objectForKey:@"errors"];
        XCTAssertEqualObjects(@"BoltsTests", [[errors objectAtIndex:0] domain]);
        XCTAssertEqual(35, (int)[[errors objectAtIndex:0] code]);
        XCTAssertEqualObjects(@"BoltsTests", [[errors objectAtIndex:1] domain]);
        XCTAssertEqual(35, (int)[[errors objectAtIndex:1] code]);

        for (int i = 0; i < kTaskCount; ++i) {
            if (i == 10 || i == 11) {
                XCTAssertNotNil(((BFTask *)[tasks objectAtIndex:i]).error);
            } else {
                XCTAssertEqual(i, [((BFTask *)[tasks objectAtIndex:i]).result intValue]);
            }
        }
        return nil;
    }] waitUntilFinished];
}

- (void)testTaskForCompletionOfAllTasksCancelled {
    NSMutableArray *tasks = [NSMutableArray array];

    const int kTaskCount = 20;
    for (int i = 0; i < kTaskCount; ++i) {
        double sleepTimeInMs = rand() % 100;
        [tasks addObject:[[BFTask taskWithDelay:sleepTimeInMs] continueWithBlock:^id(BFTask *task) {
            if (i == 10) {
                return [BFTask cancelledTask];
            }
            return @(i);
        }]];
    }

    [[[BFTask taskForCompletionOfAllTasks:tasks] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error);
        XCTAssertNil(task.exception);
        XCTAssertTrue(task.isCancelled);

        for (int i = 0; i < kTaskCount; ++i) {
            if (i == 10) {
                XCTAssertTrue(((BFTask *)[tasks objectAtIndex:i]).isCancelled);
            } else {
                XCTAssertEqual(i, [((BFTask *)[tasks objectAtIndex:i]).result intValue]);
            }
        }
        return nil;
    }] waitUntilFinished];
}

- (void)testTaskForCompletionOfAllTasksNoTasksImmediateCompletion {
    NSMutableArray *tasks = [NSMutableArray array];

    BFTask *task = [BFTask taskForCompletionOfAllTasks:tasks];
    XCTAssertTrue(task.completed);
    XCTAssertFalse(task.cancelled);
    XCTAssertFalse(task.faulted);
}

- (void)testTaskForCompletionOfAllTasksWithResultsSuccess {
    NSMutableArray *tasks = [NSMutableArray array];

    const int kTaskCount = 20;
    for (int i = 0; i < kTaskCount; ++i) {
        double sleepTimeInMs = i * 10;
        int result = i + 1;
        [tasks addObject:[[BFTask taskWithDelay:sleepTimeInMs] continueWithBlock:^id(BFTask *task) {
            return @(result);
        }]];
    }

    [[[BFTask taskForCompletionOfAllTasksWithResults:tasks] continueWithBlock:^id(BFTask *task) {
        XCTAssertFalse(task.cancelled);
        XCTAssertFalse(task.faulted);

        NSArray *results = task.result;
        for (int i = 0; i < kTaskCount; ++i) {
            NSNumber *individualResult = [results objectAtIndex:i];
            XCTAssertEqual([individualResult intValue], [((BFTask *)[tasks objectAtIndex:i]).result intValue]);
        }
        return nil;
    }] waitUntilFinished];
}

- (void)testTaskForCompletionOfAllTasksWithResultsNoTasksImmediateCompletion {
    NSMutableArray *tasks = [NSMutableArray array];

    BFTask *task = [BFTask taskForCompletionOfAllTasksWithResults:tasks];
    XCTAssertTrue(task.completed);
    XCTAssertFalse(task.cancelled);
    XCTAssertFalse(task.faulted);
    XCTAssertTrue(task.result != nil);
}

- (void)testWaitUntilFinished {
    BFTask *task = [[BFTask taskWithDelay:50] continueWithBlock:^id(BFTask *task) {
        return @"foo";
    }];

    [task waitUntilFinished];

    XCTAssertEqualObjects(@"foo", task.result);
}

- (void)testTaskFromExecutor {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0L);
    BFExecutor *queueExecutor = [BFExecutor executorWithDispatchQueue:queue];

    BFTask *task = [BFTask taskFromExecutor:queueExecutor withBlock:^id() {
        XCTAssertEqual(queue, dispatch_get_current_queue());
        return @"foo";
    }];
    [task waitUntilFinished];
    XCTAssertEqual(@"foo", task.result);
}

- (void)testExecuteImmediately {
    XCTAssertTrue([NSThread isMainThread]);
    BFTask *task = [BFTask taskWithResult:nil];
    task = [task continueWithExecutor:[BFExecutor immediateExecutor]
                            withBlock:^id(BFTask *task) {
                                XCTAssertTrue([NSThread isMainThread]);
                                return nil;
                            }];
    XCTAssertTrue(task.isCompleted);
}

- (void)testExecuteOnDispatchQueue {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0L);
    BFExecutor *queueExecutor = [BFExecutor executorWithDispatchQueue:queue];

    BFTask *task = [BFTask taskWithResult:nil];
    task = [task continueWithExecutor:queueExecutor withBlock:^id(BFTask *task) {
        XCTAssertEqual(queue, dispatch_get_current_queue());
        return nil;
    }];
    [task waitUntilFinished];
}

- (void)testExecuteOnOperationQueue {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    BFExecutor *queueExecutor = [BFExecutor executorWithOperationQueue:queue];

    BFTask *task = [BFTask taskWithResult:nil];
    task = [task continueWithExecutor:queueExecutor withBlock:^id(BFTask *task) {
        XCTAssertEqual(queue, [NSOperationQueue currentQueue]);
        return nil;
    }];
    [task waitUntilFinished];
}

- (void)testDescription {
    BFTask *task = [BFTask taskWithResult:nil];
    NSString *expected = [NSString stringWithFormat:@"<BFTask: %p; completed = YES; cancelled = NO; faulted = NO; result:(null)>", task];

    NSString *description = task.description;
    
    XCTAssertTrue([expected isEqualToString:description]);
}

@end
