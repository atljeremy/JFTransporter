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

@interface JFTransportableOperation() <NSURLSessionDataDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate>
@property (nonatomic, strong, readwrite) id<JFTransportable> transportable;
@property (nonatomic, strong, readwrite) JFTransportableResponse* response;
@property (nonatomic, strong, readwrite) NSError *error;
@end

@implementation JFTransportableOperation

@synthesize executing = _executing, finished = _finished;

#pragma mark ----------------------
#pragma mark Initialization
#pragma mark ----------------------

- (instancetype)initWithTransportable:(id<JFTransportable>)transportable acceptingStatusCodeInRange:(HTTPStatusCodeRange)statusCodeRange
{
    if (self = [super init]) {
        _transportable = transportable;
        _executing = NO;
        _finished = NO;
        _acceptableStatusCodeRange = statusCodeRange;
    }
    return self;
}

- (instancetype)initWithTransportable:(id<JFTransportable>)transportable
{
    return [self initWithTransportable:transportable acceptingStatusCodeInRange:HTTPStatusCodeRangeMake(HTTPStatusCode200, HTTPStatusCode226)];
}

+ (instancetype)operationwithTransportable:(id<JFTransportable>)transportable
{
    return [[self alloc] initWithTransportable:transportable];
}

+ (instancetype)operationwithTransportable:(id<JFTransportable>)transportable acceptingStatusCodeInRange:(HTTPStatusCodeRange)statusCodeRange
{
    return [[self alloc] initWithTransportable:transportable acceptingStatusCodeInRange:statusCodeRange];
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
                    success(_strongSelf, _strongSelf.response);
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
        
        if (![self.transportable conformsToProtocol:@protocol(JFTransportable)]) {
            [self completeOperation];
            return;
        }
        
        NSURL* url = self.transportable.URL;
        NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:url];
        urlRequest.HTTPMethod = self.transportable.HTTPMethod;
        
        if ([self.transportable respondsToSelector:@selector(HTTPBody)] && self.transportable.HTTPBody) {
            urlRequest.HTTPBody = self.transportable.HTTPBody;
            NSString* params = [NSString stringWithCString:self.transportable.HTTPBody.bytes encoding:NSUTF8StringEncoding];
            NSLog(@"HTTPBody: %@", params);
        }
        
        if (self.isCancelled) {
            [self completeOperation];
            return;
        }
        
        if ([self.transportable respondsToSelector:@selector(HTTPHeaderFields)]) {
            [self.transportable.HTTPHeaderFields enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if ([obj isKindOfClass:[NSString class]] && [key isKindOfClass:[NSString class]]) {
                    [urlRequest setValue:obj forHTTPHeaderField:key];
                }
            }];
        }
        
        if (self.isCancelled) {
            [self completeOperation];
            return;
        }
        
        dispatch_semaphore_t semephore = dispatch_semaphore_create(0);
        
        NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue currentQueue]];
        [[session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            self.response = [JFTransportableResponse responseForURLResponse:(NSHTTPURLResponse*)response withData:data];
            self.response.acceptableStatusCodeRange = self.acceptableStatusCodeRange;
            dispatch_semaphore_signal(semephore);
        }] resume];
        
        dispatch_semaphore_wait(semephore, DISPATCH_TIME_FOREVER);
        
        if (self.isCancelled) {
            [self completeOperation];
            return;
        }
        
        if (!self.response.data) {
            NSDictionary* userInfo = @{NSLocalizedDescriptionKey:@"Received empty response"};
            self.error = [NSError errorWithDomain:kJFTranportableOpertaionErrorDomain code:NSURLErrorResourceUnavailable userInfo:userInfo];
            [self completeOperation];
            return;
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
    [self main];
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

#pragma mark ----------------------
#pragma mark NSURLSessionDelegate
#pragma mark ----------------------

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    NSLog(@"Here: %s", __PRETTY_FUNCTION__);
}

#pragma mark ----------------------
#pragma mark NSURLSessionDataDelegate
#pragma mark ----------------------

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    NSLog(@"Here: %s", __PRETTY_FUNCTION__);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler
{
    NSLog(@"Here: %s", __PRETTY_FUNCTION__);
}

#pragma mark ----------------------
#pragma mark NSURLSessionDataDelegate
#pragma mark ----------------------

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    NSLog(@"Here: %s", __PRETTY_FUNCTION__);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
 needNewBodyStream:(void (^)(NSInputStream *bodyStream))completionHandler
{
    NSLog(@"Here: %s", __PRETTY_FUNCTION__);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    NSLog(@"Here: %s", __PRETTY_FUNCTION__);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    NSLog(@"Here: %s", __PRETTY_FUNCTION__);
}

@end
