/*
 *  Copyright (c) 2014, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import <UIKit/UIKit.h>

#import <libxml2/libxml/xpath.h>
#import <libxml2/libxml/HTMLparser.h>

#import "BFXMLAppLinkResolver.h"
#import "BFAppLinkResolvingPrivate.h"
#import "BFAppLink.h"
#import "BFAppLinkTarget.h"
#import "BFTask.h"
#import "BFTaskCompletionSource.h"

NSString *const BFXMLAppLinkResolverErrorDomain = @"BFXMLAppLinkResolverErrorDomain";

@implementation BFXMLAppLinkResolver

+ (instancetype)sharedInstance {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (BFTask *)appLinkFromURLInBackground:(NSURL *)url {
    return [BFFollowRedirects(url) continueWithSuccessBlock:^id(BFTask *task) {
                                           NSData *responseData = task.result[BFAppLinkResolverRedirectDataKey];
                                           NSHTTPURLResponse *response = task.result[BFAppLinkResolverRedirectResponseKey];

                                           htmlDocPtr document = htmlReadMemory(responseData.bytes, (int)responseData.length, [url.absoluteString UTF8String], [response.textEncodingName UTF8String], HTML_PARSE_RECOVER);
                                           xmlErrorPtr xmlError = xmlGetLastError();
                                           if (xmlError) {
                                               NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                                               if (xmlError->message)
                                                   [userInfo setObject:@(xmlError->message) forKey:NSLocalizedDescriptionKey];
                                               NSError *error = [NSError errorWithDomain:BFXMLAppLinkResolverErrorDomain code:(xmlError->code) userInfo:userInfo];
                                               xmlResetError(xmlError);
                                               return [BFTask taskWithError:error];
                                           }

                                           xmlXPathContextPtr context = xmlXPathNewContext(document);
                                           xmlXPathObjectPtr xpathObj = xmlXPathNodeEval(xmlDocGetRootElement(document), BAD_CAST"//meta[starts-with(@property,'al')]", context);

                                           NSMutableArray *results = [NSMutableArray array];
                                           for (NSInteger idx = 0; idx < xmlXPathNodeSetGetLength(xpathObj->nodesetval); idx++) {
                                               NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
                                               xmlNodePtr node = xmlXPathNodeSetItem(xpathObj->nodesetval, idx);
                                               xmlChar *propertyValue = xmlGetProp(node, BAD_CAST"property");
                                               if (propertyValue) {
                                                   [attributes setObject:@((const char *)propertyValue) forKey:@"property"];
                                                   xmlFree(propertyValue);
                                               }
                                               xmlChar *contentValue = xmlGetProp(node, BAD_CAST"content");
                                               if (contentValue) {
                                                   [attributes setObject:@((const char *)contentValue) forKey:@"content"];
                                                   xmlFree(contentValue);
                                               }
                                               [results addObject:attributes];
                                           }

                                           xmlXPathFreeObject(xpathObj);
                                           xmlXPathFreeContext(context);
                                           xmlFreeDoc(document);

                                           return [BFTask taskWithResult:BFAppLinkResolverAppLinkFromALData(BFAppLinkResolverParseALData(results), url)];
                                       }];
}

@end
