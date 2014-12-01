//
//  JFTransportable.h
//  JFTransporter
//
//  Created by Jeremy Fox on 11/28/14.
//  Copyright (c) 2014 Jeremy Fox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JFObjectModelMapping.h"

@protocol JFTransportable <NSObject>

@optional

#pragma mark ----------------------
#pragma mark GET
#pragma mark ----------------------

/**
 * @return The NSURL object representing the GET request to be made to the server. This must be the full and complete URL.
 */
- (NSURL*)GETURL;

/**
 * @return This must be an NSData object created using [NSJSONSerialization dataWithJSONObject:params options:0 error:&error]. This will be set as the body (KVP's) of the request.
 */
- (NSData*)GETHTTPBody;

/**
 * @return A dictionary with all custom headers to use for the request.
 */
- (NSDictionary*)GETHTTPHeaderFields;

#pragma mark ----------------------
#pragma mark POST
#pragma mark ----------------------

/**
 * @return The NSURL object representing the POST request to be made to the server. This must be the full and complete URL.
 */
- (NSURL*)POSTURL;

/**
 * @return This must be an NSData object created using [NSJSONSerialization dataWithJSONObject:params options:0 error:&error]. This will be set as the body (KVP's) of the request.
 */
- (NSData*)POSTHTTPBody;

/**
 * @return A dictionary with all custom headers to use for the request.
 */
- (NSDictionary*)POSTHTTPHeaderFields;

#pragma mark ----------------------
#pragma mark PUST
#pragma mark ----------------------

/**
 * @return The NSURL object representing the PUT request to be made to the server. This must be the full and complete URL.
 */
- (NSURL*)PUTURL;

/**
 * @return This must be an NSData object created using [NSJSONSerialization dataWithJSONObject:params options:0 error:&error]. This will be set as the body (KVP's) of the request.
 */
- (NSData*)PUTHTTPBody;

/**
 * @return A dictionary with all custom headers to use for the request.
 */
- (NSDictionary*)PUTHTTPHeaderFields;

#pragma mark ----------------------
#pragma mark PATCH
#pragma mark ----------------------

/**
 * @return The NSURL object representing the PATCH request to be made to the server. This must be the full and complete URL.
 */
- (NSURL*)PATCHURL;

/**
 * @return This must be an NSData object created using [NSJSONSerialization dataWithJSONObject:params options:0 error:&error]. This will be set as the body (KVP's) of the request.
 */
- (NSData*)PATCHHTTPBody;

/**
 * @return A dictionary with all custom headers to use for the request.
 */
- (NSDictionary*)PATCHHTTPHeaderFields;

#pragma mark ----------------------
#pragma mark DELETE
#pragma mark ----------------------

/**
 * @return The NSURL object representing the DELETE request to be made to the server. This must be the full and complete URL.
 */
- (NSURL*)DELETEURL;

/**
 * @return This must be an NSData object created using [NSJSONSerialization dataWithJSONObject:params options:0 error:&error]. This will be set as the body (KVP's) of the request.
 */
- (NSData*)DELETEHTTPBody;

/**
 * @return A dictionary with all custom headers to use for the request.
 */
- (NSDictionary*)DELETEHTTPHeaderFields;

@required

#pragma mark ----------------------
#pragma mark Object Mapping
#pragma mark ----------------------

/**
 * @return An NSDictionary that tells JFTransporter how to map the response to your model object.
 */
- (NSDictionary*)responseToObjectModelMapping;

#pragma mark ----------------------
#pragma mark Properties - Internal Use Only
#pragma mark ----------------------

/**
 * These properties are for internal use only. If you set any of these propeties yourself the value will be overriden interanally when ever you transport a request.
 */
@property (nonatomic, strong) NSURL* URL;
@property (nonatomic, strong) NSString* HTTPMethod;
@property (nonatomic, strong) NSData* HTTPBody;
@property (nonatomic, strong) NSDictionary* HTTPHeaderFields;

@end
