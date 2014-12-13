//
//  JFTransporter.h
//  JFTransporter
//
//  Created by Jeremy Fox on 11/28/14.
//  Copyright (c) 2014 Jeremy Fox. All rights reserved.
//

@import Foundation;
#import "JFTransportableOperation.h"
@protocol JFTransportable;

typedef void(^JFTransportableCompletionHandler)(id<JFTransportable> transportable, NSError* error);

@interface JFTransporter : NSObject

/**
 * @return The default transporter. This should be used for most situations/requests.
 */
+ (instancetype)defaultTransporter;

// GET
- (JFTransportableOperation*)GETTransportable:(id<JFTransportable>)transportable completionHandler:(JFTransportableCompletionHandler)completionHandler;

// POST
- (JFTransportableOperation*)POSTTransportable:(id<JFTransportable>)transportable completionHandler:(JFTransportableCompletionHandler)completionHandler;

// PUT
- (JFTransportableOperation*)PUTTransportable:(id<JFTransportable>)transportable completionHandler:(JFTransportableCompletionHandler)completionHandler;

// PATCH
- (JFTransportableOperation*)PATCHTransportable:(id<JFTransportable>)transportable completionHandler:(JFTransportableCompletionHandler)completionHandler;

// DELETE
- (JFTransportableOperation*)DELETETransportable:(id<JFTransportable>)transportable completionHandler:(JFTransportableCompletionHandler)completionHandler;

- (BOOL)cancel:(id<JFTransportable>)transportable;

@end
