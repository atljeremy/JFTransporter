//
//  JFURLRequest.m
//  JFTransporter
//
//  Created by Jeremy Fox on 1/28/15.
//  Copyright (c) 2015 Jeremy Fox. All rights reserved.
//

#import "JFURLRequest.h"
#import "JFTransporterConstants.h"
#import "JFTransportable.h"

@interface JFURLRequest ()
@property (nonatomic, strong, readwrite) id<JFTransportable> transportable;
@end

@implementation JFURLRequest

// GET
+ (instancetype)GETTransportable:(id<JFTransportable>)transportable
{
    JFTransporterAssert(transportable);
    
    JFURLRequest* request = [JFURLRequest requestWithURL:transportable.GETURL];
    request.transportable = transportable;
    request.HTTPMethod = @"GET";
    if ([transportable respondsToSelector:@selector(GETHTTPBody)]) {
        request.HTTPBody = transportable.GETHTTPBody;
    }
    if ([transportable respondsToSelector:@selector(GETHTTPHeaderFields)]) {
        NSDictionary* headerFields = transportable.GETHTTPHeaderFields;
        [headerFields enumerateKeysAndObjectsUsingBlock:^(id headerField, id value, BOOL *stop) {
            [request setValue:value forHTTPHeaderField:headerField];
        }];
    }
    
    request.acceptableStatusCodeRange = [self acceptableStatusCodeRangeForTransportable:transportable];
    
    return request;
}

// POST
+ (instancetype)POSTTransportable:(id<JFTransportable>)transportable
{
    JFTransporterAssert(transportable);
    
    JFURLRequest* request = [JFURLRequest requestWithURL:transportable.POSTURL];
    request.transportable = transportable;
    request.HTTPMethod = @"POST";
    if ([transportable respondsToSelector:@selector(POSTHTTPBody)]) {
        request.HTTPBody = transportable.POSTHTTPBody;
    }
    if ([transportable respondsToSelector:@selector(POSTHTTPHeaderFields)]) {
        NSDictionary* headerFields = transportable.POSTHTTPHeaderFields;
        [headerFields enumerateKeysAndObjectsUsingBlock:^(id headerField, id value, BOOL *stop) {
            [request setValue:value forHTTPHeaderField:headerField];
        }];
    }
    
    request.acceptableStatusCodeRange = [self acceptableStatusCodeRangeForTransportable:transportable];
    
    return request;
}

// PUT
+ (instancetype)PUTTransportable:(id<JFTransportable>)transportable
{
    JFTransporterAssert(transportable);
    
    JFURLRequest* request = [JFURLRequest requestWithURL:transportable.PUTURL];
    request.transportable = transportable;
    request.HTTPMethod = @"PUT";
    if ([transportable respondsToSelector:@selector(PUTHTTPBody)]) {
        request.HTTPBody = transportable.PUTHTTPBody;
    }
    if ([transportable respondsToSelector:@selector(PUTHTTPHeaderFields)]) {
        NSDictionary* headerFields = transportable.PUTHTTPHeaderFields;
        [headerFields enumerateKeysAndObjectsUsingBlock:^(id headerField, id value, BOOL *stop) {
            [request setValue:value forHTTPHeaderField:headerField];
        }];
    }
    
    request.acceptableStatusCodeRange = [self acceptableStatusCodeRangeForTransportable:transportable];
    
    return request;
}

// PATCH
+ (instancetype)PATCHTransportable:(id<JFTransportable>)transportable
{
    JFTransporterAssert(transportable);
    
    JFURLRequest* request = [JFURLRequest requestWithURL:transportable.PATCHURL];
    request.transportable = transportable;
    request.HTTPMethod = @"PATCH";
    if ([transportable respondsToSelector:@selector(PATCHHTTPBody)]) {
        request.HTTPBody = transportable.PATCHHTTPBody;
    }
    if ([transportable respondsToSelector:@selector(PATCHHTTPHeaderFields)]) {
        NSDictionary* headerFields = transportable.PATCHHTTPHeaderFields;
        [headerFields enumerateKeysAndObjectsUsingBlock:^(id headerField, id value, BOOL *stop) {
            [request setValue:value forHTTPHeaderField:headerField];
        }];
    }
    
    request.acceptableStatusCodeRange = [self acceptableStatusCodeRangeForTransportable:transportable];
    
    return request;
}

// DELETE
+ (instancetype)DELETETransportable:(id<JFTransportable>)transportable
{
    JFTransporterAssert(transportable);
    
    JFURLRequest* request = [JFURLRequest requestWithURL:transportable.DELETEURL];
    request.transportable = transportable;
    request.HTTPMethod = @"DELETE";
    if ([transportable respondsToSelector:@selector(DELETEHTTPBody)]) {
        request.HTTPBody = transportable.DELETEHTTPBody;
    }
    if ([transportable respondsToSelector:@selector(DELETEHTTPHeaderFields)]) {
        NSDictionary* headerFields = transportable.DELETEHTTPHeaderFields;
        [headerFields enumerateKeysAndObjectsUsingBlock:^(id headerField, id value, BOOL *stop) {
            [request setValue:value forHTTPHeaderField:headerField];
        }];
    }
    
    request.acceptableStatusCodeRange = [self acceptableStatusCodeRangeForTransportable:transportable];
    
    return request;
}

#pragma mark ----------------------
#pragma mark Helpers
#pragma mark ----------------------

+ (HTTPStatusCodeRange)acceptableStatusCodeRangeForTransportable:(id<JFTransportable>)transportable
{
    HTTPStatusCodeRange acceptableStatusCodeRange;
    if ([transportable respondsToSelector:@selector(acceptableStatusCodeRange)]) {
        acceptableStatusCodeRange = transportable.acceptableStatusCodeRange;
    } else {
        acceptableStatusCodeRange = HTTPStatusCodeRangeMake(HTTPStatusCode200, HTTPStatusCode226);
    }
    
    return acceptableStatusCodeRange;
}

@end
