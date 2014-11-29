//
//  JFTransportable.h
//  JFTransporter
//
//  Created by Jeremy Fox on 11/28/14.
//  Copyright (c) 2014 Jeremy Fox. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JFTransportable <NSObject>

@optional

/**
 * @return The NSURL object representing the GET request to be made to the server. This must be the full and complete URL.
 */
- (NSURL*)GETURL;

/**
 * @return The NSURL object representing the POST request to be made to the server. This must be the full and complete URL.
 */
- (NSURL*)POSTURL;

/**
 * @return The NSURL object representing the PUT request to be made to the server. This must be the full and complete URL.
 */
- (NSURL*)PUTURL;

/**
 * @return The NSURL object representing the PATCH request to be made to the server. This must be the full and complete URL.
 */
- (NSURL*)PATCHURL;

/**
 * @return The NSURL object representing the DELETE request to be made to the server. This must be the full and complete URL.
 */
- (NSURL*)DELETEURL;

/**
 * @return This must be an NSData object created using [NSJSONSerialization dataWithJSONObject:params options:0 error:&error]. This will be set as the body (KVP's) of the request.
 */
- (NSData*)HTTPBody;

/**
 * @return A dictionary with all custom headers to use for the request.
 */
- (NSDictionary*)allHTTPHeaderFields;


@end
