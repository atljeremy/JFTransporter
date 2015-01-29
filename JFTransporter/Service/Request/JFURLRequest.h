//
//  JFURLRequest.h
//  JFTransporter
//
//  Created by Jeremy Fox on 1/28/15.
//  Copyright (c) 2015 Jeremy Fox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JFTransporterConstants.h"
@protocol JFTransportable;

@interface JFURLRequest : NSMutableURLRequest

@property (nonatomic, strong, readonly) id<JFTransportable> transportable;
@property (nonatomic, assign) HTTPStatusCodeRange acceptableStatusCodeRange;

+ (instancetype)GETTransportable:(id<JFTransportable>)transportable;
+ (instancetype)POSTTransportable:(id<JFTransportable>)transportable;
+ (instancetype)PUTTransportable:(id<JFTransportable>)transportable;
+ (instancetype)PATCHTransportable:(id<JFTransportable>)transportable;
+ (instancetype)DELETETransportable:(id<JFTransportable>)transportable;

@end
