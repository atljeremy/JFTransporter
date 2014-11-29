//
//  JFTransportableOperation.m
//  JFTransporter
//
//  Created by Jeremy Fox on 11/28/14.
//  Copyright (c) 2014 Jeremy Fox. All rights reserved.
//

#import "JFTransportableOperation.h"
#import "JFTransportable.h"

static NSString* const kJFTranportableOpertaionErrorDomain = @"JFTranportableOpertaionErrorDomain";

@interface JFTransportableOperation()
@property (nonatomic, strong, readwrite) id<JFTransportable> request;
@property (nonatomic, strong, readwrite) NSHTTPURLResponse *response;
@property (nonatomic, strong, readwrite) NSData *responseData;
@property (nonatomic, strong, readwrite) NSError *error;
@end

@implementation JFTransportableOperation

@synthesize executing = _executing, finished = _finished;

#pragma mark ----------------------
#pragma mark Instantiation
#pragma mark ----------------------

- (instancetype)initWithTransportable:(id<JFTransportable>)transportable
{
    if (self = [super init]) {
        _transportable  = transportable;
        _executing      = NO;
        _finished       = NO;
        _response       = nil;
        _responseData   = nil;
        _error          = nil;
    }
    return self;
}

+ (instancetype)operationwithTransportable:(id<JFTransportable>)transportable
{
    return [[self alloc] initWithTransportable:transportable];
}

#pragma mark ----------------------
#pragma mark Completion Blocks
#pragma mark ----------------------

- (void)setCompletionBlockWithSuccess:(JFTransportableOperationSuccessBlock)success failure:(JFTransportableOperationErrorBlock)failure
{
    __weak typeof(self) _weakSelf = self;
    self.completionBlock = ^{
        __strong typeof(self) _strongSelf = _weakSelf;
        if (_strongSelf.error) {
            if (failure) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure(_strongSelf, _strongSelf.error);
                });
            }
        } else {
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    success(_strongSelf, _strongSelf.responseData);
                });
            }
        }
    };
}

#pragma mark ----------------------
#pragma mark NSOperation Handling
#pragma mark ----------------------

- (void)main
{
    @autoreleasepool {
        if (self.isCancelled) {
            [self completeOperation];
            return;
        }
        
        if (![self.request conformsToProtocol:@protocol(JFTransportable)]) {
            [self completeOperation];
            return;
        }
        
        NSURL* url = self.request.URL;
        NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:url];
        urlRequest.HTTPMethod = self.request.HTTPMethod;
        
        if ([self.request respondsToSelector:@selector(HTTPBody)]) {
            urlRequest.HTTPBody = self.request.HTTPBody;
            NSString* params = [NSString stringWithCString:self.request.HTTPBody.bytes encoding:NSUTF8StringEncoding];
            NSLog(@"HTTPBody: %@", params);
        }
        
        if (self.isCancelled) {
            [self completeOperation];
            return;
        }
        
        if ([self.request respondsToSelector:@selector(allHTTPHeaderFields)]) {
            [self.request.allHTTPHeaderFields enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if ([obj isKindOfClass:[NSString class]] && [key isKindOfClass:[NSString class]]) {
                    [urlRequest setValue:obj forHTTPHeaderField:key];
                }
            }];
        }
        
        if (self.isCancelled) {
            [self completeOperation];
            return;
        }
        
        NSHTTPURLResponse* urlResponse;
        NSError* error;
        self.responseData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&urlResponse error:&error];
        
        if (self.isCancelled) {
            [self completeOperation];
            return;
        }
        
        if (!self.responseData) {
            NSDictionary* userInfo = @{NSLocalizedDescriptionKey:@"Received empty response"};
            self.error = [NSError errorWithDomain:kJFTranportableOpertaionErrorDomain code:NSURLErrorResourceUnavailable userInfo:userInfo];
            [self completeOperation];
            return;
        }
        
        if (self.isCancelled) {
            [self completeOperation];
            return;
        }
        
        if (urlResponse) {
            self.response = urlResponse;
        }
        
        [self completeOperation];
    }
}

- (void)start {
    if (self.isCancelled) {
        [self willChangeValueForKey:@"isFinished"];
        _finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
    _executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)completeOperation {
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    _executing = NO;
    _finished = YES;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (BOOL)isAsynchronous {
    return YES;
}

- (NSError*)error
{
    NSError* error = nil;
    if (_error) {
        error = _error;
    } else if (!self.response) {
        NSDictionary* userInfo = @{NSLocalizedDescriptionKey:@"Request failed"};
        error = [NSError errorWithDomain:kJFTranportableOpertaionErrorDomain code:NSURLErrorResourceUnavailable userInfo:userInfo];
    }
    return error;
}


@end
