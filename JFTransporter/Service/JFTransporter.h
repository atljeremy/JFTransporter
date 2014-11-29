//
//  JFTransporter.h
//  JFTransporter
//
//  Created by Jeremy Fox on 11/28/14.
//  Copyright (c) 2014 Jeremy Fox. All rights reserved.
//

@import Foundation;
@class JFTransportableOperation;
@protocol JFTransportable;

typedef void(^JFTransportableCompletionHandler)(id<NSObject> responseModel, NSError* error);

@interface JFTransporter : NSObject

/**
 * @return The default transporter. This should be used for most situations/requests.
 */
+ (instancetype)defaultTransporter;

// GET
- (JFTransportableOperation*)GETTransportable:(id<JFTransportable>)transportable withCompletionHandler:(JFTransportableCompletionHandler)completionHandler;

// POST
- (JFTransportableOperation*)POSTTransportable:(id<JFTransportable>)transportable withCompletionHandler:(JFTransportableCompletionHandler)completionHandler;

// PUT
- (JFTransportableOperation*)PUTTransportable:(id<JFTransportable>)transportable withCompletionHandler:(JFTransportableCompletionHandler)completionHandler;

// PATCH
- (JFTransportableOperation*)PATCHTransportable:(id<JFTransportable>)transportable withCompletionHandler:(JFTransportableCompletionHandler)completionHandler;

// DELETE
- (JFTransportableOperation*)DELETETransportable:(id<JFTransportable>)transportable withCompletionHandler:(JFTransportableCompletionHandler)completionHandler;

- (BOOL)cancel:(id<JFTransportable>)transportable;

@end
