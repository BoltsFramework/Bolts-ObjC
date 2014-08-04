/*
 *  Copyright (c) 2014, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import "BFAppLinkTarget.h"

@implementation BFAppLinkTarget

+ (instancetype)appLinkTargetWithURL:(NSURL *)url
                          appStoreId:(NSString *)appStoreId
                             appName:(NSString *)appName {
    BFAppLinkTarget *target = [[self alloc] init];
    target->_URL = url;
    target->_appStoreId = appStoreId;
    target->_appName = appName;
    return target;
}

@end
