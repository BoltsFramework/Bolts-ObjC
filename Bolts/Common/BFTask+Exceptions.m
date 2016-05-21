/*
 *  Copyright (c) 2016, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

#import "BFTask+Exceptions.h"

NS_ASSUME_NONNULL_BEGIN

static BOOL taskCatchExceptions = YES;

BOOL BFTaskCatchesExceptions(void) {
    return taskCatchExceptions;
}

void BFTaskSetCatchesExceptions(BOOL catchExceptions) {
    taskCatchExceptions = catchExceptions;
}

NS_ASSUME_NONNULL_END
