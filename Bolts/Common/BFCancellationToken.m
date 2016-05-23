/*
 *  Copyright (c) 2014, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import "BFCancellationToken.h"
#import "BFCancellationTokenRegistration.h"

NS_ASSUME_NONNULL_BEGIN

@interface BFCancellationToken ()

@property (nullable, nonatomic, strong) NSMutableArray *registrations;
@property (nonatomic, strong) NSRecursiveLock *lock;
@property (nonatomic) BOOL disposed;

@end

@interface BFCancellationTokenRegistration (BFCancellationToken)

+ (instancetype)registrationWithToken:(BFCancellationToken *)token delegate:(BFCancellationBlock)delegate;

- (void)notifyDelegate;

@end

@implementation BFCancellationToken

@synthesize cancellationRequested = _cancellationRequested;

#pragma mark - Initializer

- (instancetype)init {
    self = [super init];
    if (!self) return self;

    _registrations = [NSMutableArray array];
    _lock = [NSRecursiveLock new];

    return self;
}

#pragma mark - Custom Setters/Getters

- (BOOL)isCancellationRequested {
    [self.lock lock];
    [self throwIfDisposed];
    BOOL returnValue = _cancellationRequested;
    
    [self.lock unlock];
    return returnValue;
}

- (void)cancel {
    NSArray *registrations;
    
    [self.lock lock];
    [self throwIfDisposed];
    if (!_cancellationRequested) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(cancelPrivate) object:nil];
        _cancellationRequested = YES;
        registrations = [self.registrations copy];
    }
    [self.lock unlock];

    [self notifyCancellation:registrations];
}

- (void)notifyCancellation:(NSArray *)registrations {
    for (BFCancellationTokenRegistration *registration in registrations) {
        [registration notifyDelegate];
    }
}

- (BFCancellationTokenRegistration *)registerCancellationObserverWithBlock:(BFCancellationBlock)block {
    [self.lock lock];
    BFCancellationTokenRegistration *registration = [BFCancellationTokenRegistration registrationWithToken:self delegate:[block copy]];
    [self.registrations addObject:registration];
    [self.lock unlock];
    return registration;
}

- (void)unregisterRegistration:(BFCancellationTokenRegistration *)registration {
    [self.lock lock];
    [self throwIfDisposed];
    [self.registrations removeObject:registration];
    [self.lock unlock];
}

// Delay on a non-public method to prevent interference with a user calling performSelector or
// cancelPreviousPerformRequestsWithTarget on the public method
- (void)cancelPrivate {
    [self cancel];
}

- (void)cancelAfterDelay:(int)millis {
    [self throwIfDisposed];
    if (millis < -1) {
        [NSException raise:NSInvalidArgumentException format:@"Delay must be >= -1"];
    }

    if (millis == 0) {
        [self cancel];
        return;
    }

    [self.lock lock];
    [self throwIfDisposed];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(cancelPrivate) object:nil];
    if (!self.cancellationRequested) {
        if (millis != -1) {
            double delay = (double)millis / 1000;
            [self performSelector:@selector(cancelPrivate) withObject:nil afterDelay:delay];
        }
    }
    [self.lock unlock];
}

- (void)dispose {
    [self.lock lock];
    if (!self.disposed) {
        [self.registrations makeObjectsPerformSelector:@selector(dispose)];
        self.registrations = nil;
        self.disposed = YES;
    }
    [self.lock unlock];
}

- (void)throwIfDisposed {
    if (self.disposed) {
        [NSException raise:NSInternalInconsistencyException format:@"Object already disposed"];
    }
}

@end

NS_ASSUME_NONNULL_END
