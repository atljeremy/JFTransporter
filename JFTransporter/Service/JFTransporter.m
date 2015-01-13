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
        id<JFTransportable> _transportable = operation.transportable;
        NSError* error;
        NSDictionary* response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
        if (response.count > 0) {
            [JFObjectModelMapping mapResponseObject:response toTransportable:&_transportable];
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

@end
