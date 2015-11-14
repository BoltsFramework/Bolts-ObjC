/*
 *  Copyright (c) 2014, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

@import XCTest;

#import <Bolts/Bolts.h>
#import <Bolts/BoltsVersion.h>


@interface BoltsTests : XCTestCase
@end

@implementation BoltsTests

- (void)testVersion {
    XCTAssertEqualObjects(BOLTS_VERSION, [Bolts version]);
}

@end
