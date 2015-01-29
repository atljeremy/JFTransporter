//
//  JFRequestOperation.h
//  JFTransporter
//
//  Created by Jeremy Fox on 1/28/15.
//  Copyright (c) 2015 Jeremy Fox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JFURLResponse.h"
#import "JFURLRequest.h"

@protocol JFTransportable;
@class JFRequestOperation;

static NSString* const kJFTransportableURLKey;
static NSString* const kJFTransportableHTTPMethodKey;

typedef void (^JFTransportableOperationSuccessBlock)(JFRequestOperation* operation, JFURLResponse* response);
typedef void (^JFTransportableOperationErrorBlock)(JFRequestOperation* operation, NSError* error);

@interface JFRequestOperation : NSOperation

@property (readwrite, getter=isExecuting) BOOL executing;
@property (readwrite, getter=isFinished) BOOL finished;
@property (nonatomic, strong, readonly) JFURLRequest* request;
@property (nonatomic, strong, readonly) JFURLResponse* response;
@property (nonatomic, strong, readonly) NSError *error;

/**
 * DESIGNATED INITIALIZER
 *
 * @return An instance of JFRequestOperation configured with the passed in NSURLRequest
 * @param request The NSURLRequest to be used
 */
- (instancetype)initWithRequest:(JFURLRequest*)request NS_DESIGNATED_INITIALIZER;

/**
 * CONVENIENCE INITIALIZER
 *
 * @return An instance of JFRequestOperation configured with the passed in NSURLRequest
 * @param request The NSURLRequest to be used
 */
+ (instancetype)operationWithRequest:(JFURLRequest*)request;

/**
 * @return Used to set the success and failure completion hanlders for the operation
 */
- (void)setCompletionBlockWithSuccess:(JFTransportableOperationSuccessBlock)success failure:(JFTransportableOperationErrorBlock)failure;

@end
