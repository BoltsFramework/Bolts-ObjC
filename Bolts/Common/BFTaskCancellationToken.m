//
//  BFTaskCancellationToken.m
//  Bolts
//
//  Created by Daniel Hammond on 12/5/14.
//  Copyright (c) 2014 Parse Inc. All rights reserved.
//

#import "BFTaskCancellationToken.h"

@interface BFTaskCancellationToken ()

@property (atomic, assign, readwrite, getter=isCancelled) BOOL cancelled;
@property (nonatomic, retain) NSObject *lock;

@end

@implementation BFTaskCancellationToken

- (instancetype)init
{
    self = [super init];
    _lock = [[NSObject alloc] init];
    return self;
}

- (BOOL)isCancelled {
    @synchronized (self.lock) {
        return _cancelled;
    }
}

- (void)cancel {
    @synchronized (self.lock) {
        self.cancelled = YES;
    }
}

@end
