//
//  JFRequestOperation.m
//  JFTransporter
//
//  Created by Jeremy Fox on 1/28/15.
//  Copyright (c) 2015 Jeremy Fox. All rights reserved.
//

#import "JFRequestOperation.h"
#import "JFTransportable.h"

static NSString* const kJFRequestOpertaionErrorDomain = @"JFRequestOpertaionErrorDomain";

@interface JFRequestOperation() <NSURLSessionDataDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate>
@property (nonatomic, strong, readwrite) JFURLRequest* request;
@property (nonatomic, strong, readwrite) JFURLResponse* response;
@property (nonatomic, strong, readwrite) NSError *error;
@end

@implementation JFRequestOperation

@synthesize executing = _executing, finished = _finished;

#pragma mark ----------------------
#pragma mark Initialization
#pragma mark ----------------------

- (instancetype)initWithRequest:(JFURLRequest*)request
{
    if (self = [super init]) {
        _request = request;
        _executing = NO;
        _finished = NO;
    }
    return self;
}

+ (instancetype)operationWithRequest:(JFURLRequest*)request
{
    return [[self alloc] initWithRequest:request];
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
        
        dispatch_semaphore_t semephore = dispatch_semaphore_create(0);
        
        NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue currentQueue]];
        [[session dataTaskWithRequest:self.request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            self.response = [JFURLResponse responseFromHTTPURLResponse:(NSHTTPURLResponse*)response];
            self.response.data = data;
            self.response.acceptableStatusCodeRange = self.request.acceptableStatusCodeRange;
            dispatch_semaphore_signal(semephore);
        }] resume];
        
        dispatch_semaphore_wait(semephore, DISPATCH_TIME_FOREVER);
        
        if (self.isCancelled) {
            [self completeOperation];
            return;
        }
        
        if (!self.response.data) {
            NSDictionary* userInfo = @{NSLocalizedDescriptionKey:@"Received empty response"};
            self.error = [NSError errorWithDomain:kJFRequestOpertaionErrorDomain code:NSURLErrorResourceUnavailable userInfo:userInfo];
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
        error = [NSError errorWithDomain:kJFRequestOpertaionErrorDomain code:NSURLErrorResourceUnavailable userInfo:userInfo];
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
