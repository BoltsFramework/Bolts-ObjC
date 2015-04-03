/*
 *  Copyright (c) 2014, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import "BFCancellationTokenSource.h"

#import "BFCancellationToken.h"

@interface BFCancellationTokenSource ()

@property (nonatomic, strong, readwrite) BFCancellationToken *token;
@property (atomic, assign, readwrite, getter=isCancellationRequested) BOOL cancellationRequested;
@property (atomic, assign) BOOL disposed;
@property (nonatomic, strong) NSObject *lock;

@end

@interface BFCancellationToken (BFCancellationTokenSource)

- (void)cancel;

- (void)cancelAfterDelay:(int)millis;

- (void)dispose;

- (void)throwIfDisposed;

@end

@implementation BFCancellationTokenSource

#pragma mark - Initializer

+ (instancetype)cancellationTokenSource {
    return [BFCancellationTokenSource new];
}

- (instancetype)init {
    if (self = [super init]) {
        _token = [BFCancellationToken new];
        _lock = [NSObject new];
    }
    return self;
}

#pragma mark - Custom Setters/Getters

- (BOOL)isCancellationRequested {
    return _token.isCancellationRequested;
}

- (void)cancel {
    [_token cancel];
}

- (void)cancelAfterDelay:(int)millis {
    [_token cancelAfterDelay:millis];
}

- (void)dispose {
    [_token dispose];
}

@end
