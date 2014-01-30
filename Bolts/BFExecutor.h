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

/*!
 An object that can run a given block.
 */
@interface BFExecutor : NSObject

/*!
 Returns a default executor, which runs continuations immediately until the call stack gets too
 deep, then dispatches to a new GCD queue.
 */
+ (BFExecutor *)defaultExecutor;

/*!
 Returns an executor that runs continuations on the thread where the previous task was completed.
 */
+ (BFExecutor *)immediateExecutor;

/*!
 Returns an executor that runs continuations on the main thread.
 */
+ (BFExecutor *)mainThreadExecutor;

/*!
 Returns a new executor that uses the given block execute continations.
 */
+ (BFExecutor *)executorWithBlock:(void(^)(void(^block)()))block;

/*!
 Returns a new executor that runs continuations on the given queue.
 */
+ (BFExecutor *)executorWithDispatchQueue:(dispatch_queue_t)queue;

/*!
 Returns a new executor that runs continuations on the given queue.
 */
+ (BFExecutor *)executorWithOperationQueue:(NSOperationQueue *)queue;

/*!
 Runs the given block using this executor's particular strategy.
 */
- (void)execute:(void(^)())block;

@end
