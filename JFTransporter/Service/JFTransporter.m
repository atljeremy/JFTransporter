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
@end

@implementation JFTransporter

+ (instancetype)defaultTransporter
{
    static JFTransporter* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        _queue = [NSOperationQueue new];
        _queue.name = @"JFTransporterQueue";
    }
    return self;
}

+ (JFTransportableOperation*)transport:(id<JFTransportable>)transportable withCompletionHandler:(JFTransportableCompletionHandler)completionHandler
{
    JFTransporterAssert(transportable);
    NSParameterAssert(completionHandler);
    
    JFTransportableOperation* operation = [JFTransportableOperation operationwithTransportable:transportable];
    
    [JFTransporter.defaultTransporter.queue addOperation:operation];
    
    return operation;
}

+ (BOOL)cancel:(id<JFTransportable>)transportable
{
    JFTransporterAssert(transportable);
    
    BOOL cancelled = NO;
    for (NSOperation* _operation in JFTransporter.defaultTransporter.queue.operations) {
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
