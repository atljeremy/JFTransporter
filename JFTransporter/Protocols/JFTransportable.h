//
//  JFTransportable.h
//  JFTransporter
//
//  Created by Jeremy Fox on 11/28/14.
//  Copyright (c) 2014 Jeremy Fox. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JFTransportable <NSObject>

@required

/**
 * @return The NSURL object representing the request URL to be made to the server. This must be the full and complete URL.
 */
- (NSURL*)URL;

/**
 * @return The string representing the HTTP Method to use for the request as describe here: http://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html
 */
- (NSString*)HTTPMethod;

/**
 * @return The NSObject subclass to be returned by the [JFTransporter transport:]  
 */
- (NSObject*)responseModel;

@optional

/**
 * @return This must be an NSData object created using [NSJSONSerialization dataWithJSONObject:params options:0 error:&error]. This will be set as the body (KVP's) of the request.
 */
- (NSData*)HTTPBody;

/**
 * @return A dictionary with all custom headers to use for the request.
 */
- (NSDictionary*)allHTTPHeaderFields;


@end
