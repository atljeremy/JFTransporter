//
//  JFTransportableOperation.h
//  JFTransporter
//
//  Created by Jeremy Fox on 11/28/14.
//  Copyright (c) 2014 Jeremy Fox. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef NS_DESIGNATED_INITIALIZER
#if __has_attribute(objc_designated_initializer)
#define NS_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
#else
#define NS_DESIGNATED_INITIALIZER
#endif
#endif

@protocol JFTransportable;
@class JFTransportableOperation;

static NSString* const kJFTransportableURLKey;
static NSString* const kJFTransportableHTTPMethodKey;

typedef void (^JFTransportableOperationSuccessBlock)(JFTransportableOperation* operation, id responseObject);
typedef void (^JFTransportableOperationErrorBlock)(JFTransportableOperation* operation, NSError* error);

@interface JFTransportableOperation : NSOperation

@property (readwrite, getter=isExecuting) BOOL executing;
@property (readwrite, getter=isFinished) BOOL finished;
@property (nonatomic, strong, readonly) id<JFTransportable> transportable;
@property (nonatomic, strong, readonly) NSHTTPURLResponse *response;
@property (nonatomic, strong, readonly) NSData *responseData;
@property (nonatomic, strong, readonly) NSError *error;

- (instancetype)initWithTransportable:(id<JFTransportable>)transportable NS_DESIGNATED_INITIALIZER;
+ (instancetype)operationwithTransportable:(id<JFTransportable>)transportable;

- (void)setCompletionBlockWithSuccess:(JFTransportableOperationSuccessBlock)success failure:(JFTransportableOperationErrorBlock)failure;

@end
