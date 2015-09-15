/*
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import "SampleAppDelegate.h"
#import "SampleViewController.h"
#import <Bolts/Bolts.h>

NSString *const BFSampleURLWithRefererData = @"boltssample://?foo=bar&al_applink_data=%7B%22a%22%3A%22b%22%2C%22user_agent%22%3A%22Bolts%20iOS%201.0.0%22%2C%22target_url%22%3A%22http%3A%5C%2F%5C%2Fwww.example.com%5C%2Fpath%3Fbaz%3Dbat%22%2C%22referer_app_link%22%3A%7B%22app_name%22%3A%22Facebook%22%2C%22url%22%3A%22fb%3A%5C%2F%5C%2Fsomething%5C%2F%22%7D%7D";

@implementation SampleAppDelegate

#pragma mark - Sample Implementation

+ (instancetype)sharedInstance {
    return [[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    self.receivedAppLinkURL = [BFURL URLWithURL:url];
    // Handle the app link here
    return YES;
}

#pragma mark - Setup for Sample App

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];
    [self.window setRootViewController:[[SampleViewController alloc] init]];
    return YES;
}

@end
