//
//  JFObjectModelMapping.m
//  JFTransporter
//
//  Created by Jeremy Fox on 12/1/14.
//  Copyright (c) 2014 Jeremy Fox. All rights reserved.
//

#import "JFObjectModelMapping.h"
#import "JFTransportable.h"
#import <objc/runtime.h>
@import CoreData;

NSString* const kJFObjectModelMappingEntityKey   = @"entityName";
NSString* const kJFObjectModelMappingPropertyKey = @"modelProperty";
NSString* const kJFObjectModelMappingObjectKey   = @"object";
static NSInteger const kJFObjectModelMappingArrayObjectIndex   = 0;
static NSInteger const kJFObjectModelMappingArrayPropertyIndex = 1;
static NSInteger const kJFObjectModelMappingArrayEntityIndex   = 2;

typedef NS_ENUM(NSInteger, JFObjectModelMappingArrayIndex) {
    JFObjectModelMappingArrayIndexObject,
    JFObjectModelMappingArrayIndexProperty,
    JFObjectModelMappingArrayIndexEntity,
    JFObjectModelMappingArrayIndexCount // Must always be last to represent the 'array.count'
};

NSDictionary* JFObjectModelMappingObjectDictionary(Class __CLASS__, NSString* __PROPERTY__)
{
    return @{kJFObjectModelMappingObjectKey: __CLASS__,
             kJFObjectModelMappingPropertyKey: __PROPERTY__};
}

NSArray* JFObjectModelMappingObjectArray(Class __CLASS__, NSString* __PROPERTY__)
{
    return @[__CLASS__, __PROPERTY__];
}

extern NSDictionary* JFObjectModelMappingManagedObjectDictionary(NSString* __ENTITY_NAME__, Class __CLASS__, NSString* __PROPERTY__)
{
    return @{kJFObjectModelMappingObjectKey: __CLASS__,
             kJFObjectModelMappingPropertyKey: __PROPERTY__,
             kJFObjectModelMappingEntityKey: __ENTITY_NAME__,};
}

extern NSArray* JFObjectModelMappingManagedObjectArray(NSString* __ENTITY_NAME__, Class __CLASS__, NSString* __PROPERTY__)
{
    return @[__CLASS__, __PROPERTY__, __ENTITY_NAME__];
}

@implementation JFObjectModelMapping

+ (void)mapResponseObject:(id<NSObject>)response toTransportable:(id<JFTransportable>*)transportable inContext:(NSManagedObjectContext*)context
{
    NSObject<JFTransportable>* _transportable = *transportable;
    NSDictionary* map = [*transportable responseToObjectModelMapping];
    [map enumerateKeysAndObjectsUsingBlock:^(NSString* key, id value, BOOL *stop) {
        
        id responseValue;
        
        id<NSObject> keys = [self determineKeyNestingWithKey:key];
        if ([keys isKindOfClass:[NSArray class]] && ((NSArray*)keys).count > 0) {
            NSArray* _keys = (NSArray*)keys;
            id<NSObject> _tempValue = response;
            for (NSString* subKey in _keys) {
                 _tempValue = _tempValue[subKey];
            }
            responseValue = _tempValue;
        } else {
            responseValue = response[key];
        }
        
        if ([responseValue isKindOfClass:[NSNull class]]) {
            responseValue = nil;
        }
        
        if ([value isKindOfClass:[NSDictionary class]]) {
            NSDictionary* _value = value;
            NSString* entityName = _value[kJFObjectModelMappingEntityKey];
            NSString* property = _value[kJFObjectModelMappingPropertyKey];
            id klass = _value[kJFObjectModelMappingObjectKey];
            if ([self isValidClass:klass]) {
                if (entityName) {
                    id<JFTransportable> object = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
                    [self mapResponseObject:responseValue toTransportable:&object inContext:context];
                    [_transportable setValue:object forKey:property];
                    NSError* error;
                    if (![self saveContext:context error:&error]) {
                        NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error.localizedDescription);
                    }
                } else {
                    id<JFTransportable> classInstance = [klass new];
                    [self mapResponseObject:responseValue toTransportable:&classInstance inContext:context];
                    [_transportable setValue:classInstance forKey:property];
                }
            } else {
                [self throwInvalidTransportableException];
            }
        } else if ([value isKindOfClass:[NSArray class]] && ((NSArray*)value).count == 2) {
            NSArray* _value = value;
            NSString* entityName;
            if (_value.count == JFObjectModelMappingArrayIndexCount) {
                entityName = _value[JFObjectModelMappingArrayIndexEntity];
            }
            NSString* property = _value[JFObjectModelMappingArrayIndexProperty];
            id klass = _value[JFObjectModelMappingArrayIndexObject];
            if ([self isValidClass:klass]) {
                NSMutableArray* transportableArray = [@[] mutableCopy];
                if (entityName) {
                    if ([responseValue isKindOfClass:[NSArray class]]) {
                        for (id arrayObject in (NSArray*)responseValue) {
                            id<JFTransportable> object = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
                            [self mapResponseObject:arrayObject toTransportable:&object inContext:context];
                            [transportableArray setValue:object forKey:property];
                        }
                        NSError* error;
                        if (![self saveContext:context error:&error]) {
                            NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error.localizedDescription);
                        }
                    }
                } else {
                    if ([responseValue isKindOfClass:[NSArray class]]) {
                        for (id arrayObject in (NSArray*)responseValue) {
                            id<JFTransportable> classInstance = [klass new];
                            [self mapResponseObject:arrayObject toTransportable:&classInstance inContext:context];
                            [transportableArray addObject:classInstance];
                        }
                    }
                }
                [_transportable setValue:transportableArray forKey:property];
            } else {
                [self throwInvalidTransportableException];
            }
        } else {
            NSString* property = value;
            [_transportable setValue:responseValue forKey:property];
        }
    }];
}

+ (id<NSObject>)determineKeyNestingWithKey:(NSString*)key
{
    id<NSObject> retVal = key;
    NSMutableArray* keys;
    NSRange range = [key rangeOfString:@"["];
    if (range.location != NSNotFound) {
        keys = [@[] mutableCopy];
        NSMutableArray* locations = [@[] mutableCopy];
        [key enumerateSubstringsInRange:NSMakeRange(0, key.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
            if ([substring isEqualToString:@"["] || [substring isEqualToString:@"]"]) {
                [locations addObject:[NSValue valueWithRange:substringRange]];
            }
        }];
        
        __block NSRange previousRange = NSMakeRange(NSNotFound, 0);
        [locations enumerateObjectsUsingBlock:^(NSValue* obj, NSUInteger idx, BOOL *stop) {
            NSRange substringRange;
            NSRange _range = [obj rangeValue];
            if (previousRange.location == NSNotFound) {
                substringRange = NSMakeRange(0, _range.location);
            } else {
                substringRange = NSMakeRange(previousRange.location + 1, _range.location - previousRange.location - 1);
            }
            
            NSString* _key = [key substringWithRange:substringRange];
            
            if (_key.length > 0) {
                [keys addObject:_key];
            }
            
            previousRange = _range;
        }];
    }
    
    if (keys && keys.count > 0) {
        retVal = keys;
    }
    
    return retVal;
}

#pragma mark ----------------------
#pragma mark Helper Methods
#pragma mark ----------------------

+ (BOOL)saveContext:(NSManagedObjectContext*)context error:(NSError**)error_p
{
    __block BOOL saved = NO;
    if (context) {
        [context performBlockAndWait:^{
            if ([context hasChanges] && [context save:error_p]) {
                saved = YES;
                NSLog(@"Failed to save context with error: %@", [*error_p localizedDescription]);
            }
        }];
    }
    
    return saved;
}

+ (BOOL)isValidClass:(Class)klass
{
    return class_isMetaClass(object_getClass(klass)) && class_conformsToProtocol(klass, @protocol(JFTransportable));
}

+ (void)throwInvalidTransportableException
{
    NSString* reason = @"Classes added to the object mapping dictionary returned by -responseToObjectModelMapping must conform to the JFTransportable protocol.";
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:@{NSLocalizedDescriptionKey: reason}];
}

@end
