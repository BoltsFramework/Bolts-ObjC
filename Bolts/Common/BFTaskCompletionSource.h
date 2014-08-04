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

@class BFTask;

/*!
 A BFTaskCompletionSource represents the producer side of tasks.
 It is a task that also has methods for changing the state of the
 task by settings its completion values.
 */
@interface BFTaskCompletionSource : NSObject

/*!
 Creates a new unfinished task.
 */
+ (instancetype)taskCompletionSource;

/*!
 The task associated with this TaskCompletionSource.
 */
@property (nonatomic, retain, readonly) BFTask *task;

/*!
 Completes the task by setting the result.
 Attempting to set this for a completed task will raise an exception.
 */
- (void)setResult:(id)result;

/*!
 Completes the task by setting the error.
 Attempting to set this for a completed task will raise an exception.
 */
- (void)setError:(NSError *)error;

/*!
 Completes the task by setting an exception.
 Attempting to set this for a completed task will raise an exception.
 */
- (void)setException:(NSException *)exception;

/*!
 Completes the task by marking it as cancelled.
 Attempting to set this for a completed task will raise an exception.
 */
- (void)cancel;

/*!
 Sets the result of the task if it wasn't already completed.
 @returns whether the new value was set.
 */
- (BOOL)trySetResult:(id)result;

/*!
 Sets the error of the task if it wasn't already completed.
 @returns whether the new value was set.
 */
- (BOOL)trySetError:(NSError *)error;

/*!
 Sets the exception of the task if it wasn't already completed.
 @returns whether the new value was set.
 */
- (BOOL)trySetException:(NSException *)exception;

/*!
 Sets the cancellation state of the task if it wasn't already completed.
 @returns whether the new value was set.
 */
- (BOOL)trySetCancelled;

@end
