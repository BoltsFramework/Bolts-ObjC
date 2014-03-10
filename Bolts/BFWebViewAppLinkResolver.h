//
//  BFWebViewAppLinkResolver.h
//  Bolts
//
//  Created by David Poll on 3/10/14.
//  Copyright (c) 2014 Parse Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BFAppLinkResolving.h"

/*!
 A reference implementation for an App Link resolver that uses a hidden UIWebView
 to parse the HTML containing App Link metadata.
 */
@interface BFWebViewAppLinkResolver : NSObject<BFAppLinkResolving>

/*!
 Gets an instance of a BFWebViewAppLinkResolver.
 */
+ (instancetype)resolver;

@end
