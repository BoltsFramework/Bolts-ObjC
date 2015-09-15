/*
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import "SampleViewController.h"
#import "SampleAppDelegate.h"
#import <Bolts/Bolts.h>

static void *kReceivedAppLinkURLObserverContext = &kReceivedAppLinkURLObserverContext;
static void *kReturnToRefererViewClosedObserverContext = &kReturnToRefererViewClosedObserverContext;

@interface SampleViewController () <BFAppLinkReturnToRefererControllerDelegate>

@property (nonatomic, strong) BFAppLinkReturnToRefererController *returnToRefererController;

@end

@implementation SampleViewController

#pragma mark - Sample Implementation

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self toggleRefererBackButtonIfNeeded];
    [[SampleAppDelegate sharedInstance] addObserver:self
                                         forKeyPath:@"receivedAppLinkURL"
                                            options:0
                                            context:kReceivedAppLinkURLObserverContext];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self toggleRefererBackButtonIfNeeded];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[SampleAppDelegate sharedInstance] removeObserver:self
                                            forKeyPath:@"receivedAppLinkURL"
                                               context:kReceivedAppLinkURLObserverContext];
}

// Best called at -viewWillAppear, -viewDidAppear and when receivedAppLinkURL changes.
- (void)toggleRefererBackButtonIfNeeded {
    // Provide the received AppLink (NSURL) in your app delegate
    BFURL *receivedAppLinkURL = [SampleAppDelegate sharedInstance].receivedAppLinkURL;
    if (receivedAppLinkURL.appLinkReferer != nil) {
        // If you want to display the BFAppLinkReturnToRefererController and its view
        // in a non-UINavigationController, you need to add the view to your main view
        // and manage its position/frame yourself.
        if (self.returnToRefererController == nil && self.navigationController != nil) {
            self.returnToRefererController = [[BFAppLinkReturnToRefererController alloc] initForDisplayAboveNavController:self.navigationController];

            // You can set a custom BFAppLinkReturnToRefererView:
            // self.returnToRefererController.view = [MyCustomSubclassOfBFAppLinkReturnToRefererView new];
            self.returnToRefererController.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 1);
            self.returnToRefererController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;

            // When the user taps the back link or the close button of the BFAppLinkReturnToRefererView,
            // you need to reset the receivedAppLinkURL, so all BFAppLinkReturnToRefererController can
            // remove themselves. So, observe the "closed" state of the view:
            [self.returnToRefererController.view addObserver:self
                                                  forKeyPath:@"closed"
                                                     options:0
                                                     context:kReturnToRefererViewClosedObserverContext];
        }
        [self.returnToRefererController showViewForRefererAppLink:receivedAppLinkURL.appLinkReferer];

    } else if (self.returnToRefererController != nil) {
        [self.returnToRefererController.view removeObserver:self
                                                 forKeyPath:@"closed"
                                                    context:kReturnToRefererViewClosedObserverContext];
        [self.returnToRefererController removeFromNavController];
        self.returnToRefererController = nil;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (context == kReceivedAppLinkURLObserverContext) {
        // Whenever the receivedAppLinkURL changes, check if the
        // BFAppLinkReturnToRefererView needs to be toggled.
        [self toggleRefererBackButtonIfNeeded];

    } else if (context == kReturnToRefererViewClosedObserverContext) {
        // When the view was closed, reset the receivedAppLinkURL,
        // so all BFAppLinkReturnToRefererController can remove themselves.
        if (self.returnToRefererController.view.closed) {
            [SampleAppDelegate sharedInstance].receivedAppLinkURL = nil;
            // This will trigger -observeValueForKeyPath
            // for all objects listening to receivedAppLinkURL.
        }
    } else {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

#pragma mark - Interface Events of the Sample App

- (IBAction)appLinkButtonTapped:(UIButton *)button {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:BFSampleURLWithRefererData]];
}

- (IBAction)flipButtonTapped:(UIButton *)button {
    if (self.presentingViewController != nil && self.navigationController == nil) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        SampleViewController *viewController = [[SampleViewController alloc] init];
        viewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:viewController animated:YES completion:nil];
    }
}

- (IBAction)modalButtonTapped:(UIButton *)button {
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(doneButtonTapped:)];
    SampleViewController *viewController = [[SampleViewController alloc] init];
    viewController.navigationItem.leftBarButtonItem = doneButton;

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    navigationController.navigationBar.translucent = NO;

    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)doneButtonTapped:(UIButton *)button {
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
