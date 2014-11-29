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

+ (instancetype)defaultTransporter;
+ (JFTransportableOperation*)transport:(id<JFTransportable>)transportable withCompletionHandler:(JFTransportableCompletionHandler)completionHandler;
+ (BOOL)cancel:(id<JFTransportable>)transportable;

@end
