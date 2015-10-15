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

static NSString *const BFURLWithRefererData = @"bolts://?foo=bar&al_applink_data=%7B%22a%22%3A%22b%22%2C%22user_agent%22%3A%22Bolts%20iOS%201.0.0%22%2C%22target_url%22%3A%22http%3A%5C%2F%5C%2Fwww.example.com%5C%2Fpath%3Fbaz%3Dbat%22%2C%22referer_app_link%22%3A%7B%22app_name%22%3A%22Facebook%22%2C%22url%22%3A%22fb%3A%5C%2F%5C%2Fsomething%5C%2F%22%7D%7D";
static NSString *const BFURLWithRefererUrlNoName = @"bolts://?foo=bar&al_applink_data=%7B%22a%22%3A%22b%22%2C%22user_agent%22%3A%22Bolts%20iOS%201.0.0%22%2C%22target_url%22%3A%22http%3A%5C%2F%5C%2Fwww.example.com%5C%2Fpath%3Fbaz%3Dbat%22%2C%22referer_app_link%22%3A%7B%22url%22%3A%22fb%3A%5C%2F%5C%2Fsomething%5C%2F%22%7D%7D";
static NSString *const BFURLWithRefererNameNoUrl = @"bolts://?foo=bar&al_applink_data=%7B%22a%22%3A%22b%22%2C%22user_agent%22%3A%22Bolts%20iOS%201.0.0%22%2C%22target_url%22%3A%22http%3A%5C%2F%5C%2Fwww.example.com%5C%2Fpath%3Fbaz%3Dbat%22%2C%22referer_app_link%22%3A%7B%22app_name%22%3A%22Facebook%22%7D%7D";

@interface AppLinkReturnToRefererViewTests : XCTestCase

@end

@implementation AppLinkReturnToRefererViewTests

- (void)testInitReturnsValidView {
    BFAppLinkReturnToRefererView *view = [[BFAppLinkReturnToRefererView alloc] init];

    XCTAssert(view);
}

- (void)testNoRefererDataResultsInZeroHeight {
    BFAppLinkReturnToRefererView *view = [[BFAppLinkReturnToRefererView alloc] init];

    CGSize sizeThatFits = [view sizeThatFits:CGSizeMake(100.0, 100.0)];

    XCTAssertEqualWithAccuracy(0.0, sizeThatFits.height, FLT_EPSILON);
}

- (void)testNoRefererNameResultsInZeroHeight {
    NSURL *url = [NSURL URLWithString:BFURLWithRefererUrlNoName];
    BFAppLink *appLink = [[BFURL URLWithURL:url] appLinkReferer];

    BFAppLinkReturnToRefererView *view = [[BFAppLinkReturnToRefererView alloc] init];
    view.refererAppLink = appLink;

    CGSize sizeThatFits = [view sizeThatFits:CGSizeMake(100.0, 100.0)];

    XCTAssertEqualWithAccuracy(0.0, sizeThatFits.height, FLT_EPSILON);
}

- (void)testNoRefererUrlResultsInZeroHeight {
    NSURL *url = [NSURL URLWithString:BFURLWithRefererNameNoUrl];
    BFAppLink *appLink = [[BFURL URLWithURL:url] appLinkReferer];

    BFAppLinkReturnToRefererView *view = [[BFAppLinkReturnToRefererView alloc] init];
    view.refererAppLink = appLink;

    CGSize sizeThatFits = [view sizeThatFits:CGSizeMake(100.0, 100.0)];

    XCTAssertEqualWithAccuracy(0.0, sizeThatFits.height, FLT_EPSILON);
}

- (void)testValidRefererDataResultsInNonZeroSizeThatFits {
    NSURL *url = [NSURL URLWithString:BFURLWithRefererData];
    BFAppLink *appLink = [[BFURL URLWithURL:url] appLinkReferer];

    BFAppLinkReturnToRefererView *view = [[BFAppLinkReturnToRefererView alloc] init];
    view.refererAppLink = appLink;

    CGSize sizeThatFits = [view sizeThatFits:CGSizeMake(100.0, 100.0)];

    XCTAssert(sizeThatFits.height > 0.0);
    XCTAssert(sizeThatFits.width > 0.0);
}

- (void)testIncludesStatusBarResultsInLargerHeight {
    NSURL *url = [NSURL URLWithString:BFURLWithRefererData];
    BFAppLink *appLink = [[BFURL URLWithURL:url] appLinkReferer];

    BFAppLinkReturnToRefererView *view = [[BFAppLinkReturnToRefererView alloc] init];
    view.refererAppLink = appLink;
    view.includeStatusBarInSize = BFIncludeStatusBarInSizeNever;
    CGSize sizeThatFitsNotIncludingStatusBar = [view sizeThatFits:CGSizeMake(100.0, 100.0)];

    view.includeStatusBarInSize = BFIncludeStatusBarInSizeAlways;
    CGSize sizeThatFitsIncludingStatusBar = [view sizeThatFits:CGSizeMake(100.0, 100.0)];

    XCTAssert(sizeThatFitsIncludingStatusBar.height > sizeThatFitsNotIncludingStatusBar.height);
}

- (void)testNotIncludingStatusBarResultsInSmallerHeight {
    NSURL *url = [NSURL URLWithString:BFURLWithRefererData];
    BFAppLink *appLink = [[BFURL URLWithURL:url] appLinkReferer];

    BFAppLinkReturnToRefererView *view = [[BFAppLinkReturnToRefererView alloc] init];
    view.refererAppLink = appLink;
    CGSize sizeThatFitsIncludingStatusBar = [view sizeThatFits:CGSizeMake(100.0, 100.0)];

    view.includeStatusBarInSize = BFIncludeStatusBarInSizeNever;
    CGSize sizeThatFitsNotIncludingStatusBar = [view sizeThatFits:CGSizeMake(100.0, 100.0)];

    XCTAssert(sizeThatFitsIncludingStatusBar.height > sizeThatFitsNotIncludingStatusBar.height);
}

@end
