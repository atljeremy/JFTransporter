//
//  JFTransporter.m
//  JFTransporter
//
//  Created by Jeremy Fox on 11/28/14.
//  Copyright (c) 2014 Jeremy Fox. All rights reserved.
//

#import "JFTransporter.h"
#import "JFRequestOperation.h"
#import "JFTransportable.h"
#import "JFObjectModelMapping.h"
#import "JFDataManager.h"
#import "JFURLRequest.h"
#import <objc/runtime.h>

@interface JFTransporter ()
@property (nonatomic, strong) NSOperationQueue* queue;
- (JFRequestOperation*)enqueueOperation:(JFRequestOperation*)operation completionHandler:(JFTransportableCompletionHandler)completionHandler;
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

- (void)setParentContext:(NSManagedObjectContext*)context
{
    NSAssert(context && [context isKindOfClass:[NSManagedObjectContext class]], @"Only a valid NSManagedObjectContext can be used with JFTransporter.");
    [JFDataManager.sharedManager setParentContext:context];
}

#pragma mark ----------------------
#pragma mark Request Execution
#pragma mark ----------------------

// GET
- (JFRequestOperation*)GETTransportable:(id<JFTransportable>)transportable completionHandler:(JFTransportableCompletionHandler)completionHandler
{
    JFURLRequest* request = [JFURLRequest GETTransportable:transportable];
    return [self enqueueOperation:[JFRequestOperation operationWithRequest:request] completionHandler:completionHandler];
}

// POST
- (JFRequestOperation*)POSTTransportable:(id<JFTransportable>)transportable completionHandler:(JFTransportableCompletionHandler)completionHandler
{
    JFURLRequest* request = [JFURLRequest POSTTransportable:transportable];
    return [self enqueueOperation:[JFRequestOperation operationWithRequest:request] completionHandler:completionHandler];
}

// PUT
- (JFRequestOperation*)PUTTransportable:(id<JFTransportable>)transportable completionHandler:(JFTransportableCompletionHandler)completionHandler
{
    JFURLRequest* request = [JFURLRequest PUTTransportable:transportable];
    return [self enqueueOperation:[JFRequestOperation operationWithRequest:request] completionHandler:completionHandler];
}

// PATCH
- (JFRequestOperation*)PATCHTransportable:(id<JFTransportable>)transportable completionHandler:(JFTransportableCompletionHandler)completionHandler
{
    JFURLRequest* request = [JFURLRequest PATCHTransportable:transportable];
    return [self enqueueOperation:[JFRequestOperation operationWithRequest:request] completionHandler:completionHandler];
}

// DELETE
- (JFRequestOperation*)DELETETransportable:(id<JFTransportable>)transportable completionHandler:(JFTransportableCompletionHandler)completionHandler
{
    JFURLRequest* request = [JFURLRequest DELETETransportable:transportable];
    return [self enqueueOperation:[JFRequestOperation operationWithRequest:request] completionHandler:completionHandler];
}

- (JFRequestOperation*)enqueueOperation:(JFRequestOperation*)operation completionHandler:(JFTransportableCompletionHandler)completionHandler
{
    NSParameterAssert(operation);
    NSParameterAssert(completionHandler);
    [operation setCompletionBlockWithSuccess:^(JFRequestOperation *operation, JFURLResponse* response) {
        NSError* error;
        id<JFTransportable> _transportable;
        if ([response hasAcceptableStatusCode]) {
            _transportable = operation.request.transportable;
            [JFObjectModelMapping mapResponseObject:response.JSONObject toTransportable:&_transportable];
        } else {
            NSString* description = [NSString stringWithFormat:@"Response status code is not within the acceptable range. Status code was %li", response.statusCode];
            error = [NSError errorWithDomain:NSRangeException code:9867 userInfo:@{NSLocalizedDescriptionKey: description}];
        }
        completionHandler(_transportable, error);
    } failure:^(JFRequestOperation *operation, NSError* error) {
        completionHandler(operation.request.transportable, error);
    }];
    
    [self.queue addOperation:operation];
    
    return operation;
}

#pragma mark ----------------------
#pragma mark Cancelation
#pragma mark ----------------------

- (void)cancel:(JFRequestOperation*)requestOperation
{
    [requestOperation cancel];
}

@end
