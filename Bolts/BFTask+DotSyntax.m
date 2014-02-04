//
//  BFTask+DotSyntax.m
//  Bolts
//
//  Created by Yasuhiro Inami on 2014/02/04.
//  Copyright (c) 2014年 Parse Inc. All rights reserved.
//

#import "BFTask+DotSyntax.h"

@implementation BFTask (DotSyntax)

+ (BFTask * (^)(id))taskWithResult
{
    return ^BFTask*(id result) {
        return [self taskWithResult:result];
    };
}

+ (BFTask * (^)(NSError *))taskWithError
{
    return ^BFTask*(NSError *error) {
        return [self taskWithError:error];
    };
}

+ (BFTask * (^)(NSException *))taskWithException
{
    return ^BFTask*(NSException *exception) {
        return [self taskWithException:exception];
    };
}

+ (BFTask * (^)(NSArray *))taskForCompletionOfAllTasks
{
    return ^BFTask*(NSArray *result) {
        return [self taskForCompletionOfAllTasks:result];
    };
}

+ (BFTask * (^)(int))taskWithDelay
{
    return ^BFTask*(int millis) {
        return [self taskWithDelay:millis];
    };
}

- (BFTask * (^)(BFContinuationBlock block))continueWithBlock
{
    return ^BFTask*(BFContinuationBlock block) {
        return [self continueWithBlock:block];
    };
}

- (BFTask * (^)(BFContinuationBlock block))continueWithSuccessBlock
{
    return ^BFTask*(BFContinuationBlock block) {
        return [self continueWithSuccessBlock:block];
    };
}

- (BFTask * (^)(BFExecutor *executor))continueWithExecutor
{
    return ^BFTask*(BFExecutor *executor) {
        self.executor = executor;
        return self;
    };
}

- (BFTask * (^)(BFContinuationBlock block))withBlock
{
    return self.continueWithBlock;
}

- (BFTask * (^)(BFContinuationBlock block))withSuccessBlock
{
    return self.continueWithSuccessBlock;
}

@end
