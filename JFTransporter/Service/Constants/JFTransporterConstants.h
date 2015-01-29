//
//  JFTransporterConstants.h
//  JFTransporter
//
//  Created by Jeremy Fox on 1/26/15.
//  Copyright (c) 2015 Jeremy Fox. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef NS_DESIGNATED_INITIALIZER
#if __has_attribute(objc_designated_initializer)
#define NS_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
#else
#define NS_DESIGNATED_INITIALIZER
#endif
#endif

#define JFTransporterAssert(_TRANSPORTER) NSAssert([_TRANSPORTER conformsToProtocol:@protocol(JFTransportable)], @"Invliad transportable - must conform to JFTransportable protocol.")

typedef NS_ENUM(NSUInteger, HTTPStatusCode) {
    HTTPStatusCode100 = 100, // 'Continue',
    HTTPStatusCode101 = 101, // 'Switching Protocols',
    HTTPStatusCode102 = 102, // 'Processing',
    HTTPStatusCode200 = 200, // 'OK',
    HTTPStatusCode201 = 201, // 'Created',
    HTTPStatusCode202 = 202, // 'Accepted',
    HTTPStatusCode203 = 203, // 'Non-Authoritative Information',
    HTTPStatusCode204 = 204, // 'No Content',
    HTTPStatusCode205 = 205, // 'Reset Content',
    HTTPStatusCode206 = 206, // 'Partial Content',
    HTTPStatusCode207 = 207, // 'Multi-Status',
    HTTPStatusCode208 = 208, // 'Already Reported',
    HTTPStatusCode226 = 226, // 'IM Used',
    HTTPStatusCode300 = 300, // 'Multiple Choices',
    HTTPStatusCode301 = 301, // 'Moved Permanently',
    HTTPStatusCode302 = 302, // 'Found',
    HTTPStatusCode303 = 303, // 'See Other',
    HTTPStatusCode304 = 304, // 'Not Modified',
    HTTPStatusCode305 = 305, // 'Use Proxy',
    HTTPStatusCode306 = 306, // 'Reserved',
    HTTPStatusCode307 = 307, // 'Temporary Redirect',
    HTTPStatusCode308 = 308, // 'Permanent Redirect',
    HTTPStatusCode400 = 400, // 'Bad Request',
    HTTPStatusCode401 = 401, // 'Unauthorized',
    HTTPStatusCode402 = 402, // 'Payment Required',
    HTTPStatusCode403 = 403, // 'Forbidden',
    HTTPStatusCode404 = 404, // 'Not Found',
    HTTPStatusCode405 = 405, // 'Method Not Allowed',
    HTTPStatusCode406 = 406, // 'Not Acceptable',
    HTTPStatusCode407 = 407, // 'Proxy Authentication Required',
    HTTPStatusCode408 = 408, // 'Request Timeout',
    HTTPStatusCode409 = 409, // 'Conflict',
    HTTPStatusCode410 = 410, // 'Gone',
    HTTPStatusCode411 = 411, // 'Length Required',
    HTTPStatusCode412 = 412, // 'Precondition Failed',
    HTTPStatusCode413 = 413, // 'Request Entity Too Large',
    HTTPStatusCode414 = 414, // 'Request-URI Too Long',
    HTTPStatusCode415 = 415, // 'Unsupported Media Type',
    HTTPStatusCode416 = 416, // 'Requested Range Not Satisfiable',
    HTTPStatusCode417 = 417, // 'Expectation Failed',
    HTTPStatusCode422 = 422, // 'Unprocessable Entity',
    HTTPStatusCode423 = 423, // 'Locked',
    HTTPStatusCode424 = 424, // 'Failed Dependency',
    HTTPStatusCode425 = 425, // 'Reserved for WebDAV advanced collections expired proposal',
    HTTPStatusCode426 = 426, // 'Upgrade Required',
    HTTPStatusCode427 = 427, // 'Unassigned',
    HTTPStatusCode428 = 428, // 'Precondition Required',
    HTTPStatusCode429 = 429, // 'Too Many Requests',
    HTTPStatusCode430 = 430, // 'Unassigned',
    HTTPStatusCode431 = 431, // 'Request Header Fields Too Large',
    HTTPStatusCode500 = 500, // 'Internal Server Error',
    HTTPStatusCode501 = 501, // 'Not Implemented',
    HTTPStatusCode502 = 502, // 'Bad Gateway',
    HTTPStatusCode503 = 503, // 'Service Unavailable',
    HTTPStatusCode504 = 504, // 'Gateway Timeout',
    HTTPStatusCode505 = 505, // 'HTTP Version Not Supported',
    HTTPStatusCode506 = 506, // 'Variant Also Negotiates (Experimental)',
    HTTPStatusCode507 = 507, // 'Insufficient Storage',
    HTTPStatusCode508 = 508, // 'Loop Detected',
    HTTPStatusCode509 = 509, // 'Unassigned',
    HTTPStatusCode510 = 510, // 'Not Extended',
    HTTPStatusCode511 = 511  // 'Network Authentication Required'
};

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

@interface JFTransporterConstants : NSObject

@end
