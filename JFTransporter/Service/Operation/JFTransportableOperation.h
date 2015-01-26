//
//  JFTransportableOperation.h
//  JFTransporter
//
//  Created by Jeremy Fox on 11/28/14.
//  Copyright (c) 2014 Jeremy Fox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JFTransportableResponse.h"

@protocol JFTransportable;
@class JFTransportableOperation;

static NSString* const kJFTransportableURLKey;
static NSString* const kJFTransportableHTTPMethodKey;

typedef void (^JFTransportableOperationSuccessBlock)(JFTransportableOperation* operation, JFTransportableResponse* response);
typedef void (^JFTransportableOperationErrorBlock)(JFTransportableOperation* operation, NSError* error);

@interface JFTransportableOperation : NSOperation

@property (readwrite, getter=isExecuting) BOOL executing;
@property (readwrite, getter=isFinished) BOOL finished;
@property (nonatomic, strong, readonly) id<JFTransportable> transportable;
@property (nonatomic, strong, readonly) JFTransportableResponse* response;
@property (nonatomic, assign) HTTPStatusCodeRange acceptableStatusCodeRange;
@property (nonatomic, strong, readonly) NSError *error;

/**
 * DESIGNATED INITIALIZER
 *
 * @return An instance of JFTransportableOperation configured with the passed in JFTransportable and HTTPStatusCodeRange
 * @param transportable The JFTransportable to be used to build the request
 * @param statusCodeRange The acceptable HTTPStatusCodeRange to be used for validating an acceptable status code for the request/response
 */
- (instancetype)initWithTransportable:(id<JFTransportable>)transportable acceptingStatusCodeInRange:(HTTPStatusCodeRange)statusCodeRange NS_DESIGNATED_INITIALIZER;

/**
 * CONVENIENCE INITIALIZER
 *
 * @return An instance of JFTransportableOperation configured with the passed in JFTransportable. This initializer will use a default acceptable HTTPStatusCodeRange consisting of a range of 200 - 226
 * @param transportable The JFTransportable to be used to build the request
 */
- (instancetype)initWithTransportable:(id<JFTransportable>)transportable;

/**
 * CONVENIENCE INITIALIZER
 *
 * @return An instance of JFTransportableOperation configured with the passed in JFTransportable. This initializer will use a default acceptable HTTPStatusCodeRange consisting of a range of 200 - 226
 * @param transportable The JFTransportable to be used to build the request
 */
+ (instancetype)operationwithTransportable:(id<JFTransportable>)transportable;

/**
 * CONVENIENCE INITIALIZER
 *
 * @return An instance of JFTransportableOperation configured with the passed in JFTransportable and HTTPStatusCodeRange
 * @param transportable The JFTransportable to be used to build the request
 * @param statusCodeRange The acceptable HTTPStatusCodeRange to be used for validating an acceptable status code for the request/response
 */
+ (instancetype)operationwithTransportable:(id<JFTransportable>)transportable acceptingStatusCodeInRange:(HTTPStatusCodeRange)statusCodeRange;

/**
 * @return Used to set the success and failure completion hanlders for the operation.
 */
- (void)setCompletionBlockWithSuccess:(JFTransportableOperationSuccessBlock)success failure:(JFTransportableOperationErrorBlock)failure;

@end
