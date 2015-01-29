//
//  JFTransportableResponse.h
//  JFTransporter
//
//  Created by Jeremy Fox on 1/26/15.
//  Copyright (c) 2015 Jeremy Fox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JFTransporterConstants.h"

@interface JFURLResponse : NSHTTPURLResponse

@property (nonatomic, copy) NSData* data;
@property (nonatomic, strong) id<NSObject> JSONObject;
@property (nonatomic, strong) NSError* error;
@property (nonatomic, assign) HTTPStatusCodeRange acceptableStatusCodeRange;

- (instancetype)initWithHTTPURLResponse:(NSHTTPURLResponse*)HTTPURLResponse NS_DESIGNATED_INITIALIZER;
+ (instancetype)responseFromHTTPURLResponse:(NSHTTPURLResponse*)HTTPURLResponse;

- (BOOL)hasAcceptableStatusCode;

@end
