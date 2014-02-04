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

@class BFExecutor;
@class BFTask;

/*!
 A block that can act as a contination for a task.
 */
typedef id(^BFContinuationBlock)(BFTask *task);

/*!
 The consumer view of a Task. A BFTask has methods to
 inspect the state of the task, and to add continuations to
 be run once the task is complete.
 */
@interface BFTask : NSObject

/*!
 Creates a task that is already completed with the given result.
 */
+ (BFTask *)taskWithResult:(id)result;

/*!
 Creates a task that is already completed with the given error.
 */
+ (BFTask *)taskWithError:(NSError *)error;

/*!
 Creates a task that is already completed with the given exception.
 */
+ (BFTask *)taskWithException:(NSException *)exception;

/*!
 Creates a task that is already cancelled.
 */
+ (BFTask *)cancelledTask;

/*!
 Returns a task that will be completed (with result == nil) once
 all of the input tasks have completed.
 */
+ (BFTask *)taskForCompletionOfAllTasks:(NSArray *)tasks;

/*!
 Returns a task that will be completed a certain amount of time in the future.
 @param millis The approximate number of milliseconds to wait before the
 task will be finished (with result == nil).
 */
+ (BFTask *)taskWithDelay:(int)millis;

@property (nonatomic) BFExecutor *executor;
   
// Properties that will be set on the task once it is completed.

/*!
 The result of a successful task.
 */
- (id)result;

/*!
 The error of a failed task.
 */
- (NSError *)error;

/*!
 The exception of a failed task.
 */
- (NSException *)exception;

/*!
 Whether this task has been cancelled.
 */
- (BOOL)isCancelled;

/*!
 Whether this task has completed.
 */
- (BOOL)isCompleted;

/*!
 Enqueues the given block to be run once this task is complete.
 This method uses a default execution strategy. The block will be
 run on the thread where the previous task completes, unless the
 the stack depth is too deep, in which case it will be run on a
 dispatch queue with default priority.
 @param block The block to be run once this task is complete.
 @returns A task that will be completed after block has run.
 If block returns a BFTask, then the task returned from
 this method will not be completed until that task is completed.
 */
- (BFTask *)continueWithBlock:(BFContinuationBlock)block;

/*!
 Enqueues the given block to be run once this task is complete.
 @param executor A BFExecutor responsible for determining how the
 continuation block will be run.
 @param block The block to be run once this task is complete.
 @returns A task that will be completed after block has run.
 If block returns a BFTask, then the task returned from
 this method will not be completed until that task is completed.
 */
- (BFTask *)continueWithExecutor:(BFExecutor *)executor
                       withBlock:(BFContinuationBlock)block;

/*!
 Identical to continueWithBlock:, except that the block is only run
 if this task did not produce a cancellation, error, or exception.
 If it did, then the failure will be propagated to the returned
 task.
 @param block The block to be run once this task is complete.
 @returns A task that will be completed after block has run.
 If block returns a BFTask, then the task returned from
 this method will not be completed until that task is completed.
 */
- (BFTask *)continueWithSuccessBlock:(BFContinuationBlock)block;

/*!
 Identical to continueWithExecutor:withBlock:, except that the block
 is only run if this task did not produce a cancellation, error, or
 exception. If it did, then the failure will be propagated to the
 returned task.
 @param executor A BFExecutor responsible for determining how the
 continuation block will be run.
 @param block The block to be run once this task is complete.
 @returns A task that will be completed after block has run.
 If block returns a BFTask, then the task returned from
 this method will not be completed until that task is completed.
 */
- (BFTask *)continueWithExecutor:(BFExecutor *)executor
                withSuccessBlock:(BFContinuationBlock)block;

/*!
 Waits until this operation is completed.
 This method is inefficient and consumes a thread resource while
 it's running. It should be avoided. This method logs a warning
 message if it is used on the main thread.
 */
- (void)waitUntilFinished;

@end
