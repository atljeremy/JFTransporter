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

#define JFTransporterAssert(_TRANSPORTER) NSAssert([_TRANSPORTER conformsToProtocol:@protocol(JFTransportable)], @"Invliad transportable - must conform to JFTransportable protocol.")

@interface JFTransporter ()
@property (nonatomic, strong) NSOperationQueue* queue;
- (JFTransportableOperation*)transport:(id<JFTransportable>)transportable HTTPMethod:(NSString*)HTTPMethod completionHandler:(JFTransportableCompletionHandler)completionHandler;
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
#pragma mark Request Execution
#pragma mark ----------------------

// GET
- (JFTransportableOperation*)GETTransportable:(id<JFTransportable>)transportable withCompletionHandler:(JFTransportableCompletionHandler)completionHandler
{
    return [self transport:transportable HTTPMethod:@"GET" completionHandler:completionHandler];
}

// POST
- (JFTransportableOperation*)POSTTransportable:(id<JFTransportable>)transportable withCompletionHandler:(JFTransportableCompletionHandler)completionHandler
{
    return [self transport:transportable HTTPMethod:@"POST" completionHandler:completionHandler];
}

// PUT
- (JFTransportableOperation*)PUTTransportable:(id<JFTransportable>)transportable withCompletionHandler:(JFTransportableCompletionHandler)completionHandler
{
    return [self transport:transportable HTTPMethod:@"PUT" completionHandler:completionHandler];
}

// PATCH
- (JFTransportableOperation*)PATCHTransportable:(id<JFTransportable>)transportable withCompletionHandler:(JFTransportableCompletionHandler)completionHandler
{
    return [self transport:transportable HTTPMethod:@"PATCH" completionHandler:completionHandler];
}

// DELETE
- (JFTransportableOperation*)DELETETransportable:(id<JFTransportable>)transportable withCompletionHandler:(JFTransportableCompletionHandler)completionHandler
{
    return [self transport:transportable HTTPMethod:@"DELETE" completionHandler:completionHandler];
}

- (JFTransportableOperation*)transport:(id<JFTransportable>)transportable HTTPMethod:(NSString*)HTTPMethod completionHandler:(JFTransportableCompletionHandler)completionHandler
{
    JFTransporterAssert(transportable);
    NSParameterAssert(completionHandler);
    NSParameterAssert(HTTPMethod);
    
    JFTransportableOperation* operation = [JFTransportableOperation operationwithTransportable:transportable];
    
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
