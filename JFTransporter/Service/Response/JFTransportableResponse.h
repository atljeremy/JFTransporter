//
//  JFTransportableResponse.h
//  JFTransporter
//
//  Created by Jeremy Fox on 1/26/15.
//  Copyright (c) 2015 Jeremy Fox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JFTransporterConstants.h"

typedef struct _HTTPStatusCodeRange {
    NSUInteger beginningCode;
    NSUInteger endingCode;
} HTTPStatusCodeRange;

NS_INLINE HTTPStatusCodeRange HTTPStatusCodeRangeMake(HTTPStatusCode beginningCode, HTTPStatusCode endingCode) {
    HTTPStatusCodeRange range;
    range.beginningCode = beginningCode;
    range.endingCode = endingCode;
    return range;
}

NS_INLINE BOOL HTTPStatusCodeWithinRange(HTTPStatusCode statusCode, HTTPStatusCodeRange range) {
    return ((statusCode >= range.beginningCode) && (range.endingCode >= statusCode));
}

@interface JFTransportableResponse : NSObject

@property (nonatomic, copy) NSHTTPURLResponse* HTTPResponse;
@property (nonatomic, copy) NSData* data;
@property (nonatomic, strong) id<NSObject> JSONObject;
@property (nonatomic, strong) NSError* error;
@property (nonatomic, assign) HTTPStatusCodeRange acceptableStatusCodeRange;

- (instancetype)initWithURLResponse:(NSHTTPURLResponse*)response withData:(NSData*)data NS_DESIGNATED_INITIALIZER;
+ (instancetype)responseForURLResponse:(NSHTTPURLResponse*)response withData:(NSData*)data;

- (BOOL)hasAcceptableStatusCode;

@end
