/*
 *  Copyright (c) 2014, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import "BFCancellationTokenRegistration.h"

#import "BFCancellationToken.h"

NS_ASSUME_NONNULL_BEGIN

@interface BFCancellationTokenRegistration ()

@property (nonatomic, weak) BFCancellationToken *token;
@property (nullable, nonatomic, strong) BFCancellationBlock cancellationObserverBlock;
@property (nonatomic, strong) NSRecursiveLock *lock;
@property (nonatomic) BOOL disposed;

@end

@interface BFCancellationToken (BFCancellationTokenRegistration)

- (void)unregisterRegistration:(BFCancellationTokenRegistration *)registration;

@end

@implementation BFCancellationTokenRegistration

+ (instancetype)registrationWithToken:(BFCancellationToken *)token delegate:(BFCancellationBlock)delegate {
    BFCancellationTokenRegistration *registration = [BFCancellationTokenRegistration new];
    registration.token = token;
    registration.cancellationObserverBlock = delegate;
    return registration;
}

- (instancetype)init {
    self = [super init];
    if (!self) return self;

    _lock = [NSRecursiveLock new];
    
    return self;
}

- (void)dispose {
    [self.lock lock];
    if (self.disposed) {
        [self.lock unlock];
        return;
    }
    self.disposed = YES;
    [self.lock unlock];
    
    BFCancellationToken *token = self.token;
    if (token != nil) {
        [token unregisterRegistration:self];
        self.token = nil;
    }
    self.cancellationObserverBlock = nil;
}

- (void)notifyDelegate {
    [self.lock lock];
    [self throwIfDisposed];
    self.cancellationObserverBlock();
    [self.lock unlock];
}

- (void)throwIfDisposed {
    NSAssert(!self.disposed, @"Object already disposed");
}

@end

NS_ASSUME_NONNULL_END
