//
//  JFObjectModelMapping.h
//  JFTransporter
//
//  Created by Jeremy Fox on 12/1/14.
//  Copyright (c) 2014 Jeremy Fox. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreData;

@protocol JFTransportable;

extern NSString* const kJFObjectModelMappingEntityKey;
extern NSString* const kJFObjectModelMappingPropertyKey;
extern NSString* const kJFObjectModelMappingObjectKey;

extern NSDictionary* JFObjectModelMappingObjectDictionary(Class __CLASS__, NSString* __PROPERTY__);
extern NSArray* JFObjectModelMappingObjectArray(Class __CLASS__, NSString* __PROPERTY__);

/**
 * For use with CoreData NSManagedObject subclasses.
 */
extern NSDictionary* JFObjectModelMappingManagedObjectDictionary(NSString* __ENTITY_NAME__, Class __CLASS__, NSString* __PROPERTY__);
extern NSArray* JFObjectModelMappingManagedObjectArray(NSString* __ENTITY_NAME__, Class __CLASS__, NSString* __PROPERTY__);

@interface JFObjectModelMapping : NSObject

+ (void)mapResponseObject:(id<NSObject>)response toTransportable:(id<JFTransportable>*)transportable inContext:(NSManagedObjectContext*)context;

@end
