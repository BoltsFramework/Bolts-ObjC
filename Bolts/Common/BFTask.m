/*
 *  Copyright (c) 2014, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import "BFTask.h"

#import <libkern/OSAtomic.h>

#import "BFExecutor.h"
#import "BFTaskCompletionSource.h"
#import "Bolts.h"

__attribute__ ((noinline)) void warnBlockingOperationOnMainThread() {
    NSLog(@"Warning: A long-running operation is being executed on the main thread. \n"
          " Break on warnBlockingOperationOnMainThread() to debug.");
}

@interface BFTask () {
    id _result;
    NSError *_error;
    NSException *_exception;
    BOOL _cancelled;
}

@property (nonatomic, retain, readwrite) NSObject *lock;
@property (nonatomic, retain, readwrite) NSCondition *condition;
@property (nonatomic, assign, readwrite) BOOL completed;
@property (nonatomic, retain, readwrite) NSMutableArray *callbacks;
@end

@implementation BFTask

#pragma mark - Initializer

- (id)init {
    if (self = [super init]) {
        self.lock = [[NSObject alloc] init];
        self.condition = [[NSCondition alloc] init];
        self.callbacks = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Task Class methods

+ (BFTask *)taskWithResult:(id)result {
    BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
    tcs.result = result;
    return tcs.task;
}

+ (BFTask *)taskWithError:(NSError *)error {
    BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
    tcs.error = error;
    return tcs.task;
}

+ (BFTask *)taskWithException:(NSException *)exception {
    BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
    tcs.exception = exception;
    return tcs.task;
}

+ (BFTask *)cancelledTask {
    BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
    [tcs cancel];
    return tcs.task;
}

+ (BFTask *)taskForCompletionOfAllTasks:(NSArray *)tasks {
    __block int32_t total = (int32_t)tasks.count;
    if (total == 0) {
        return [BFTask taskWithResult:nil];
    }
    
    __block int32_t cancelled = 0;
    NSObject *lock = [[NSObject alloc] init];
    NSMutableArray *errors = [NSMutableArray array];
    NSMutableArray *exceptions = [NSMutableArray array];

    BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
    for (BFTask *task in tasks) {
        [task continueWithBlock:^id(BFTask *task) {
            if (task.isCancelled) {
                OSAtomicIncrement32(&cancelled);
            } else if (task.exception) {
                @synchronized (lock) {
                    [exceptions addObject:task.exception];
                }
            } else if (task.error) {
                @synchronized (lock) {
                    [errors addObject:task.error];
                }
            }
            
            if (OSAtomicDecrement32(&total) == 0) {
                if (cancelled > 0) {
                    [tcs cancel];
                } else if (exceptions.count > 0) {
                    if (exceptions.count == 1) {
                        tcs.exception = [exceptions objectAtIndex:0];
                    } else {
                        NSException *exception =
                            [NSException exceptionWithName:@"BFMultipleExceptionsException"
                                                    reason:@"There were multiple exceptions."
                                                  userInfo:@{ @"exceptions": exceptions }];
                        tcs.exception = exception;
                    }
                } else if (errors.count > 0) {
                    if (errors.count == 1) {
                        tcs.error = [errors objectAtIndex:0];
                    } else {
                        NSError *error = [NSError errorWithDomain:@"bolts"
                                                             code:kBFMultipleErrorsError
                                                         userInfo:@{ @"errors": errors }];
                        tcs.error = error;
                    }
                } else {
                    tcs.result = nil;
                }
            }
            return nil;
        }];
    }
    return tcs.task;
}

+ (BFTask *)taskWithDelay:(int)millis {
    BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, millis * NSEC_PER_MSEC);
    dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        tcs.result = nil;
    });
    return tcs.task;
}

+ (BFTask *)taskFromExecutor:(BFExecutor *)executor
                   withBlock:(id (^)())block {
    return [[self taskWithResult:nil] continueWithExecutor:executor withBlock:block];
}

#pragma mark - Custom Setters/Getters

- (id)result {
    @synchronized (self.lock) {
        return _result;
    }
}

- (void)setResult:(id)result {
    if (![self trySetResult:result]) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Cannot set the result on a completed task."];
    }
}

- (BOOL)trySetResult:(id)result {
    @synchronized (self.lock) {
        if (self.completed) {
            return NO;
        }
        self.completed = YES;
        _result = result;
        [self runContinuations];
        return YES;
    }
}

- (NSError *)error {
    @synchronized (self.lock) {
        return _error;
    }
}

- (void)setError:(NSError *)error {
    if (![self trySetError:error]) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Cannot set the error on a completed task."];
    }
}

- (BOOL)trySetError:(NSError *)error {
    @synchronized (self.lock) {
        if (self.completed) {
            return NO;
        }
        self.completed = YES;
        _error = error;
        [self runContinuations];
        return YES;
    }
}

- (NSException *)exception {
    @synchronized (self.lock) {
        return _exception;
    }
}

- (void)setException:(NSException *)exception {
    if (![self trySetException:exception]) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Cannot set the exception on a completed task."];
    }
}

- (BOOL)trySetException:(NSException *)exception {
    @synchronized (self.lock) {
        if (self.completed) {
            return NO;
        }
        self.completed = YES;
        _exception = exception;
        [self runContinuations];
        return YES;
    }
}

- (BOOL)isCancelled {
    @synchronized (self.lock) {
        return _cancelled;
    }
}

- (void)cancel {
    @synchronized (self.lock) {
        if (![self trySetCancelled]) {
            [NSException raise:NSInternalInconsistencyException
                        format:@"Cannot cancel a completed task."];
        }
    }
}

- (BOOL)trySetCancelled {
    @synchronized (self.lock) {
        if (self.completed) {
            return NO;
        }
        self.completed = YES;
        _cancelled = YES;
        [self runContinuations];
        return YES;
    }
}

- (BOOL)isCompleted {
    @synchronized (self.lock) {
        return _completed;
    }
}

- (void)setCompleted {
    @synchronized (self.lock) {
        _completed = YES;
    }
}

- (void)runContinuations {
    @synchronized (self.lock) {
        [self.condition lock];
        [self.condition broadcast];
        [self.condition unlock];
        for (void (^callback)() in self.callbacks) {
            callback();
        }
        [self.callbacks removeAllObjects];
    }
}

#pragma mark - Chaining methods

- (BFTask *)continueWithExecutor:(BFExecutor *)executor
                       withBlock:(BFContinuationBlock)block {
    BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
    
    // Capture all of the state that needs to used when the continuation is complete.
    void (^wrappedBlock)() = ^() {
        [executor execute:^{
            id result = nil;
            @try {
                result = block(self);
            } @catch (NSException *exception) {
                tcs.exception = exception;
                return;
            }
            if ([result isKindOfClass:[BFTask class]]) {
                [(BFTask *)result continueWithBlock:^id(BFTask *task) {
                    if (task.isCancelled) {
                        [tcs cancel];
                    } else if (task.exception) {
                        tcs.exception = task.exception;
                    } else if (task.error) {
                        tcs.error = task.error;
                    } else {
                        tcs.result = task.result;
                    }
                    return nil;
                }];
            } else {
                tcs.result = result;
            }
        }];
    };
    
    BOOL completed;
    @synchronized (self.lock) {
        completed = self.completed;
        if (!completed) {
            [self.callbacks addObject:[wrappedBlock copy]];
        }
    }
    if (completed) {
        wrappedBlock();
    }
    
    return tcs.task;
}

- (BFTask *)continueWithBlock:(BFContinuationBlock)block {
    return [self continueWithExecutor:[BFExecutor defaultExecutor] withBlock:block];
}

- (BFTask *)continueWithExecutor:(BFExecutor *)executor
                withSuccessBlock:(BFContinuationBlock)block {
    return [self continueWithExecutor:executor withBlock:^id(BFTask *task) {
        if (task.error || task.exception || task.isCancelled) {
            return task;
        } else {
            return block(task);
        }
    }];
}

- (BFTask *)continueWithSuccessBlock:(BFContinuationBlock)block {
    return [self continueWithExecutor:[BFExecutor defaultExecutor] withSuccessBlock:block];
}

#pragma mark - Syncing Task (Avoid it)

- (void)warnOperationOnMainThread {
    warnBlockingOperationOnMainThread();
}

- (void)waitUntilFinished {
    if ([NSThread isMainThread]) {
        [self warnOperationOnMainThread];
    }

    @synchronized (self.lock) {
        if (self.isCompleted) {
            return;
        }
        [self.condition lock];
    }
    [self.condition wait];
    [self.condition unlock];
}

@end
