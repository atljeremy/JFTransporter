//
//  JFTransporter.m
//  JFTransporter
//
//  Created by Jeremy Fox on 11/28/14.
//  Copyright (c) 2014 Jeremy Fox. All rights reserved.
//

#import "JFTransporter.h"
#import "JFTransportableOperation.h"
#import "JFTransportable.h"
#import "JFObjectModelMapping.h"
#import "JFDataManager.h"
#import <objc/runtime.h>

#define JFTransporterAssert(_TRANSPORTER) NSAssert([_TRANSPORTER conformsToProtocol:@protocol(JFTransportable)], @"Invliad transportable - must conform to JFTransportable protocol.")

typedef NS_ENUM(NSInteger, HTTPStatusCode) {
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

@interface JFTransporter ()
@property (nonatomic, strong) NSOperationQueue* queue;
- (JFTransportableOperation*)transport:(id<JFTransportable>)transportable completionHandler:(JFTransportableCompletionHandler)completionHandler;
@end

@implementation JFTransporter

#pragma mark ----------------------
#pragma mark Initialization
#pragma mark ----------------------

+ (instancetype)defaultTransporter
{
    static JFTransporter* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    if (self = [super init]) {
        _queue = [NSOperationQueue new];
        _queue.name = @"JFTransporterQueue";
    }
    return self;
}

#pragma mark ----------------------
#pragma mark CoreData Support
#pragma mark ----------------------

- (void)setManagedObjectContext:(NSManagedObjectContext*)context
{
    NSAssert(context && [context isKindOfClass:[NSManagedObjectContext class]], @"Only a valid NSManagedObjectContext can be used with JFTransporter.");
    [JFDataManager.sharedManager setManagedObjectContext:context];
}

#pragma mark ----------------------
#pragma mark Request Execution
#pragma mark ----------------------

// GET
- (JFTransportableOperation*)GETTransportable:(id<JFTransportable>)transportable completionHandler:(JFTransportableCompletionHandler)completionHandler
{
    transportable.URL = [transportable GETURL];
    transportable.HTTPMethod = @"GET";
    if ([transportable respondsToSelector:@selector(GETHTTPBody)]) {
        transportable.HTTPBody = [transportable GETHTTPBody];
    }
    if ([transportable respondsToSelector:@selector(GETHTTPHeaderFields)]) {
        transportable.HTTPHeaderFields = [transportable GETHTTPHeaderFields];
    }
    return [self transport:transportable completionHandler:completionHandler];
}

// POST
- (JFTransportableOperation*)POSTTransportable:(id<JFTransportable>)transportable completionHandler:(JFTransportableCompletionHandler)completionHandler
{
    transportable.URL = transportable.POSTURL;
    transportable.HTTPMethod = @"POST";
    if ([transportable respondsToSelector:@selector(POSTHTTPBody)]) {
        transportable.HTTPBody = transportable.POSTHTTPBody;
    }
    if ([transportable respondsToSelector:@selector(POSTHTTPHeaderFields)]) {
        transportable.HTTPHeaderFields = transportable.POSTHTTPHeaderFields;
    }
    
    return [self transport:transportable completionHandler:completionHandler];
}

// PUT
- (JFTransportableOperation*)PUTTransportable:(id<JFTransportable>)transportable completionHandler:(JFTransportableCompletionHandler)completionHandler
{
    transportable.URL = transportable.PUTURL;
    transportable.HTTPMethod = @"PUT";
    if ([transportable respondsToSelector:@selector(PUTHTTPBody)]) {
        transportable.HTTPBody = transportable.PUTHTTPBody;
    }
    if ([transportable respondsToSelector:@selector(PUTHTTPHeaderFields)]) {
        transportable.HTTPHeaderFields = transportable.PUTHTTPHeaderFields;
    }
    
    return [self transport:transportable completionHandler:completionHandler];
}

// PATCH
- (JFTransportableOperation*)PATCHTransportable:(id<JFTransportable>)transportable completionHandler:(JFTransportableCompletionHandler)completionHandler
{
    transportable.URL = transportable.PATCHURL;
    transportable.HTTPMethod = @"PATCH";
    if ([transportable respondsToSelector:@selector(PATCHHTTPBody)]) {
        transportable.HTTPBody = transportable.PATCHHTTPBody;
    }
    if ([transportable respondsToSelector:@selector(PATCHHTTPBody)]) {
        transportable.HTTPHeaderFields = transportable.PATCHHTTPHeaderFields;
    }
    
    return [self transport:transportable completionHandler:completionHandler];
}

// DELETE
- (JFTransportableOperation*)DELETETransportable:(id<JFTransportable>)transportable completionHandler:(JFTransportableCompletionHandler)completionHandler
{
    transportable.URL = transportable.DELETEURL;
    transportable.HTTPMethod = @"DELETE";
    if ([transportable respondsToSelector:@selector(DELETEHTTPBody)]) {
        transportable.HTTPBody = transportable.DELETEHTTPBody;
    }
    if ([transportable respondsToSelector:@selector(DELETEHTTPHeaderFields)]) {
        transportable.HTTPHeaderFields = transportable.DELETEHTTPHeaderFields;
    }
    
    return [self transport:transportable completionHandler:completionHandler];
}

- (JFTransportableOperation*)transport:(id<JFTransportable>)transportable completionHandler:(JFTransportableCompletionHandler)completionHandler
{
    JFTransporterAssert(transportable);
    NSParameterAssert(completionHandler);
    
    JFTransportableOperation* operation = [JFTransportableOperation operationwithTransportable:transportable];
    [operation setCompletionBlockWithSuccess:^(JFTransportableOperation *operation, id responseObject) {
        NSError* error;
        id<JFTransportable> _transportable;
        if ([self responseHasAccceptibleStatusCode:operation.response]) {
            _transportable = operation.transportable;
            NSDictionary* response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
            if (response.count > 0) {
                [JFObjectModelMapping mapResponseObject:response toTransportable:&_transportable];
            }
        } else {
            NSString* description = [NSString stringWithFormat:@"Response status code is not within the accetpile range. Status code was %li", operation.response.statusCode];
            error = [NSError errorWithDomain:NSRangeException code:9867 userInfo:@{NSLocalizedDescriptionKey: description}];
        }
        completionHandler(_transportable, error);
    } failure:^(JFTransportableOperation *operation, NSError* error) {
        completionHandler(operation.transportable, error);
    }];
    
    [self.queue addOperation:operation];
    
    return operation;
}

#pragma mark ----------------------
#pragma mark Cancelation
#pragma mark ----------------------

- (BOOL)cancel:(id<JFTransportable>)transportable
{
    JFTransporterAssert(transportable);
    
    BOOL cancelled = NO;
    for (NSOperation* _operation in self.queue.operations) {
        if ([_operation isKindOfClass:[JFTransportableOperation class]] && !_operation.isCancelled) {
            JFTransportableOperation* transportableOperation = (JFTransportableOperation*)_operation;
            if ([transportableOperation.transportable isEqual:transportable]) {
                [transportableOperation cancel];
            }
        }
    }
    
    return cancelled;
}

#pragma mark ----------------------
#pragma mark Response Validation
#pragma mark ----------------------

- (BOOL)responseHasAccceptibleStatusCode:(NSHTTPURLResponse*)response
{
    NSRange range = NSMakeRange(HTTPStatusCode200, HTTPStatusCode226);
    BOOL inRange = NSLocationInRange(response.statusCode, range);
    return inRange;
}

@end
