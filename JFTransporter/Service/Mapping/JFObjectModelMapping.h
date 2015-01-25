//
//  JFObjectModelMapping.h
//  JFTransporter
//
//  Created by Jeremy Fox on 12/1/14.
//  Copyright (c) 2014 Jeremy Fox. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JFTransportable;

/**
 * Nested Object Mapping Helpers
 */
extern NSDictionary* JFObjectModelMappingObjectDictionary(Class __CLASS__, NSString* __PROPERTY__);
extern NSArray* JFObjectModelMappingObjectArray(Class __CLASS__, NSString* __PROPERTY__);

/**
 * Date parsing
 */
extern NSDictionary* JFObjectModelMappingDateUsingFormat(NSString* __DATE_FORMAT__, NSString* __PROPERTY__);

/**
 * Helpers for use with Core Data and NSManagedObject subclasses
 */
extern NSDictionary* JFObjectModelMappingManagedObjectDictionary(NSString* __ENTITY_NAME__, Class __CLASS__, NSString* __PROPERTY__);
extern id JFObjectModelMappingManagedObjectCollection(NSString* __ENTITY_NAME__, Class __COLLECTION_CLASS__, Class __MANAGED_OBJECT_CLASS__, NSString* __PROPERTY__);

/**
 * Relationhips
 */
extern NSDictionary* JFObjectModelMappingToOneRelationship(Class __CLASS__);
extern NSDictionary* JFObjectModelMappingToManyRelationship(Class __CLASS__);

@interface JFObjectModelMapping : NSObject

+ (void)mapResponseObject:(id<NSObject>)response toTransportable:(id<JFTransportable>*)transportable;

@end
