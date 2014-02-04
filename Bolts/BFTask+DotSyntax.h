//
//  BFTask+DotSyntax.h
//  Bolts
//
//  Created by Yasuhiro Inami on 2014/02/04.
//  Copyright (c) 2014年 Parse Inc. All rights reserved.
//

#import "BFTask.h"

@interface BFTask (DotSyntax)

+ (BFTask * (^)(id result))taskWithResult;
+ (BFTask * (^)(NSError *error))taskWithError;
+ (BFTask * (^)(NSException *exception))taskWithException;
+ (BFTask * (^)(NSArray *result))taskForCompletionOfAllTasks;
+ (BFTask * (^)(int millis))taskWithDelay;

- (BFTask * (^)(BFContinuationBlock block))continueWithBlock;
- (BFTask * (^)(BFContinuationBlock block))continueWithSuccessBlock;

- (BFTask * (^)(BFExecutor *executor))continueWithExecutor;
- (BFTask * (^)(BFContinuationBlock block))withBlock;
- (BFTask * (^)(BFContinuationBlock block))withSuccessBlock;

@end
