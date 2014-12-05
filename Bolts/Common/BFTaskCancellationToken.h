//
//  BFTaskCancellationToken.h
//  Bolts
//
//  Created by Daniel Hammond on 12/5/14.
//  Copyright (c) 2014 Parse Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BFTaskCancellationToken : NSObject

@property (nonatomic, assign, readonly, getter=isCancelled) BOOL cancelled;
- (void)cancel;

@end
