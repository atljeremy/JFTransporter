//
//  JFObjectModelMapping.h
//  JFTransporter
//
//  Created by Jeremy Fox on 12/1/14.
//  Copyright (c) 2014 Jeremy Fox. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JFTransportable;

extern NSString* const kJFObjectModelMappingPropertyKey;
extern NSString* const kJFObjectModelMappingObjectKey;

#define JFObjectModelMappingObjectDictionary(_CLASS_, _PROPERTY_) @{kJFObjectModelMappingObjectKey: _CLASS_, kJFObjectModelMappingPropertyKey: _PROPERTY_}

#define JFObjectModelMappingObjectArray(_CLASS_, _PROPERTY_) @[_CLASS_, _PROPERTY_]

@interface JFObjectModelMapping : NSObject

+ (void)mapResponseObject:(id<NSObject>)response toTransportable:(id<JFTransportable>*)transportable;

@end
