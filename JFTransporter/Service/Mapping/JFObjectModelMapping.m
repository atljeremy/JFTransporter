//
//  JFObjectModelMapping.m
//  JFTransporter
//
//  Created by Jeremy Fox on 12/1/14.
//  Copyright (c) 2014 Jeremy Fox. All rights reserved.
//

#import "JFObjectModelMapping.h"
#import "JFTransportable.h"
#import "JFSynchronizable.h"
#import <objc/runtime.h>
#import "JFDataManager.h"
@import CoreData;

NSString* const kJFObjectModelMappingEntityKey       = @"JFObjectModelMappingEntityKey";
NSString* const kJFObjectModelMappingPropertyKey     = @"JFObjectModelMappingPropertyKey";
NSString* const kJFObjectModelMappingObjectKey       = @"JFObjectModelMappingObjectKey";
NSString* const kJFObjectModelMappingDateFormatKey   = @"JFObjectModelMappingDateFormatKey";
NSString* const kJFObjectModelMappingRelationshipKey = @"JFObjectModelMappingRelationshipKey";

NSString* const kJFObjectModelMappingToOneRelationship  = @"JFObjectModelMappingToOneRelationship";
NSString* const kJFObjectModelMappingToManyRelationship = @"JFObjectModelMappingToManyRelationship";

typedef NS_ENUM(NSInteger, JFObjectModelMappingArrayIndex) {
    JFObjectModelMappingArrayIndexObject,
    JFObjectModelMappingArrayIndexProperty,
    JFObjectModelMappingArrayIndexEntity,
    JFObjectModelMappingArrayIndexCollection,
    JFObjectModelMappingArrayIndexCount // Must always be last to represent the 'array.count'
};

#pragma mark ----------------------
#pragma mark Functions
#pragma mark ----------------------

NSDictionary* JFObjectModelMappingToOneRelationship(Class __CLASS__)
{
    return @{kJFObjectModelMappingObjectKey: __CLASS__,
             kJFObjectModelMappingRelationshipKey: kJFObjectModelMappingToOneRelationship};
}

NSDictionary* JFObjectModelMappingToManyRelationship(Class __CLASS__)
{
    return @{kJFObjectModelMappingObjectKey: __CLASS__,
             kJFObjectModelMappingRelationshipKey: kJFObjectModelMappingToManyRelationship};
}

NSDictionary* JFObjectModelMappingObjectDictionary(Class __CLASS__, NSString* __PROPERTY__)
{
    return @{kJFObjectModelMappingObjectKey: __CLASS__,
             kJFObjectModelMappingPropertyKey: __PROPERTY__};
}

NSArray* JFObjectModelMappingObjectArray(Class __CLASS__, NSString* __PROPERTY__)
{
    return @[__CLASS__, __PROPERTY__, @"", [NSArray class]];
}

NSDictionary* JFObjectModelMappingDateUsingFormat(NSString* __DATE_FORMAT__, NSString* __PROPERTY__)
{
    return @{kJFObjectModelMappingDateFormatKey: __DATE_FORMAT__,
             kJFObjectModelMappingPropertyKey: __PROPERTY__};
}

NSDictionary* JFObjectModelMappingManagedObjectDictionary(NSString* __ENTITY_NAME__, Class __CLASS__, NSString* __PROPERTY__)
{
    return @{kJFObjectModelMappingObjectKey: __CLASS__,
             kJFObjectModelMappingPropertyKey: __PROPERTY__,
             kJFObjectModelMappingEntityKey: __ENTITY_NAME__,};
}

NSSet* JFObjectModelMappingManagedObjectSet(NSString* __ENTITY_NAME__, Class __CLASS__, NSString* __PROPERTY__)
{
    return [NSSet setWithObjects:__CLASS__, __PROPERTY__, __ENTITY_NAME__, nil];
}

id JFObjectModelMappingManagedObjectCollection(NSString* __ENTITY_NAME__, Class __COLLECTION_CLASS__, Class __MANAGED_OBJECT_CLASS__, NSString* __PROPERTY__)
{
    return @[__MANAGED_OBJECT_CLASS__, __PROPERTY__, __ENTITY_NAME__, __COLLECTION_CLASS__];
}

@implementation JFObjectModelMapping

+ (void)mapResponseObject:(id<NSObject>)response toTransportable:(id<JFTransportable> *)transportable
{
    NSObject<JFTransportable>* _transportable = *transportable;
    NSDictionary* map = [*transportable responseToObjectModelMapping];
    [map enumerateKeysAndObjectsUsingBlock:^(NSString* key, id value, BOOL *stop) {
        
        id responseObject = [self valueFromResponse:response forKey:key];
        
        if ([value isKindOfClass:[NSDictionary class]]) {
            
            [self mapResponseObject:responseObject toTransportable:_transportable withValuesDictionary:value];
            
        } else if ([value isKindOfClass:[NSArray class]]) {
            
            [self mapResponseObject:responseObject toTransportable:_transportable withValuesArray:value];
            
        } else {
            
            NSString* property = value;
            [_transportable setValue:responseObject forKey:property];

        }
    }];
}

#pragma mark ----------------------
#pragma mark Dictionary Mapping
#pragma mark ----------------------

+ (void)mapResponseObject:(id)responseObject toTransportable:(NSObject *)_transportable withValuesDictionary:(NSDictionary*)values
{
    NSDictionary* _values = values;
    
    NSString* dateFormat = _values[kJFObjectModelMappingDateFormatKey];
    NSString* property = _values[kJFObjectModelMappingPropertyKey];
    
    if (dateFormat.length > 0 && property.length > 0) {
        NSDate* date = [self dateFromString:responseObject withFormat:dateFormat];
        [_transportable setValue:date forKey:property];
    } else {
        NSString* entityName = _values[kJFObjectModelMappingEntityKey];
        Class klass = _values[kJFObjectModelMappingObjectKey];
        NSAssert([self isValidClass:klass], @"Classes added to the object mapping dictionary returned by -responseToObjectModelMapping must conform to the JFTransportable protocol.");
        if (entityName.length > 0) {
            NSManagedObject<JFTransportable>* managedObject;
            
            BOOL performSync = NO;
            NSString* syncDateAttribute;
            NSString* responseDateKey;
            NSString* responseDateFormat;
            __block NSMutableString* predicateFormat;
            NSDictionary* predicateValueIDs;
            if ([klass conformsToProtocol:@protocol(JFSynchronizable)]) {
                performSync = YES;
                syncDateAttribute       = [klass managedObjectSyncDateAttribute];
                responseDateKey         = [klass responseObjectSyncDateKey];
                responseDateFormat      = [klass responseObjectSyncDateFormat];
                predicateFormat         = [[klass syncPredicateFormat] mutableCopy];
                predicateValueIDs       = [klass syncPredicateValueIdentifiers];
                NSAssert(syncDateAttribute.length > 0, @"Must provide a value for +managedObjectSyncDateAttribute");
                NSAssert(responseDateKey.length > 0, @"Must provide a value for +responseObjectSyncDateKey");
                NSAssert(responseDateFormat.length > 0, @"Must provide a value for +responseObjectSyncDateFormat");
                NSAssert(predicateFormat.length > 0, @"Must provide a value for +syncPredicateFormat");
                NSAssert(predicateValueIDs.count > 0, @"Must provide a value for +syncPredicateValueIdentifiers");
            }
            
            if (performSync) {
                [predicateValueIDs enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    NSString* value = [[self valueFromResponse:responseObject forKey:obj] stringValue];
                    [predicateFormat replaceOccurrencesOfString:key withString:value options:NSCaseInsensitiveSearch range:NSMakeRange(0, predicateFormat.length)];
                }];
                
                managedObject = [JFDataManager.sharedManager existingObjectWithPredicateFormat:predicateFormat forEntityName:entityName];
            }
            
            if (!managedObject) {
                managedObject = [JFDataManager.sharedManager insertNewObjectForEntityForName:entityName];
            }
            
            NSDate* remoteUpdateAtDate = [self dateFromString:responseObject[responseDateKey] withFormat:responseDateFormat];
            NSDate* localUpdatedAtDate = [managedObject valueForKey:syncDateAttribute];
            if (!localUpdatedAtDate || [localUpdatedAtDate compare:remoteUpdateAtDate] == NSOrderedAscending) {
                // Remote object is newer
                [self mapResponseObject:responseObject toTransportable:&managedObject];
            } else {
                // Local object is newer
            }
            
            if ([[_transportable class] respondsToSelector:@selector(relationshipKeyPaths)]) {
                NSDictionary* relationshipKeyPaths = [[_transportable class] relationshipKeyPaths];
                NSDictionary* relationshipDictionary = [relationshipKeyPaths valueForKey:property];
                __block Class relationshipClass = relationshipDictionary[kJFObjectModelMappingObjectKey];
                __block NSString* relationship;
                __block NSString* relationshipKeyPath;
                if (relationshipClass && [relationshipClass isEqual:managedObject.class] && [relationshipClass respondsToSelector:@selector(relationshipKeyPaths)]) {
                    relationshipKeyPaths = [relationshipClass relationshipKeyPaths];
                    [relationshipKeyPaths enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSDictionary* obj, BOOL *stop) {
                        if ([obj[kJFObjectModelMappingObjectKey] isEqual:_transportable.class]) {
                            relationship = obj[kJFObjectModelMappingRelationshipKey];
                            relationshipKeyPath = key;
                        }
                    }];
                }
                
                if (relationshipKeyPath) {
                    if ([relationship isEqualToString:kJFObjectModelMappingToManyRelationship]) {
                        id objects = [managedObject valueForKey:relationshipKeyPath];
                        if ([objects isKindOfClass:[NSSet class]] || [objects isKindOfClass:[NSOrderedSet class]]) {
                            id mutableObjects = [objects mutableCopy];
                            [mutableObjects addObject:_transportable];
                            [managedObject setValue:mutableObjects forKey:relationshipKeyPath];
                        }
                    } else if ([relationship isEqualToString:kJFObjectModelMappingToOneRelationship]) {
                        [_transportable setValue:managedObject forKey:property];
                    }
                } else {
                    [_transportable setValue:managedObject forKey:property];
                }
            }
            
            NSError* error;
            if (![JFDataManager.sharedManager saveContextWithError:&error]) {
                if (error) {
                    NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error.localizedDescription);
                }
            }
        } else {
            id<JFTransportable> classInstance = [(id)klass new];
            [self mapResponseObject:responseObject toTransportable:&classInstance];
            [_transportable setValue:classInstance forKey:property];
        }
    }
}

#pragma mark ----------------------
#pragma mark Collections Mapping
#pragma mark ----------------------

+ (void)mapResponseObject:(id)responseObject toTransportable:(NSObject *)_transportable withValuesArray:(NSArray *)values
{
    NSArray* _values = values;
    NSString* entityName = _values[JFObjectModelMappingArrayIndexEntity];
    id collection = _values[JFObjectModelMappingArrayIndexCollection];
    NSString* property = _values[JFObjectModelMappingArrayIndexProperty];
    
    Class klass = _values[JFObjectModelMappingArrayIndexObject];
    NSAssert([self isValidClass:klass], @"Classes added to the object mapping dictionary returned by -responseToObjectModelMapping must conform to the JFTransportable protocol.");
    
    id transportableCollection = [[collection new] mutableCopy];
    if (entityName.length > 0) {
        
        BOOL performSync = NO;
        NSString* syncDateAttribute;
        NSString* responseDateKey;
        NSString* responseDateFormat;
        __block NSMutableString* predicateFormat;
        NSDictionary* predicateValueIDs;
        if ([klass conformsToProtocol:@protocol(JFSynchronizable)]) {
            performSync = YES;
            syncDateAttribute       = [klass managedObjectSyncDateAttribute];
            responseDateKey         = [klass responseObjectSyncDateKey];
            responseDateFormat      = [klass responseObjectSyncDateFormat];
            predicateFormat         = [[klass syncPredicateFormat] mutableCopy];
            predicateValueIDs       = [klass syncPredicateValueIdentifiers];
            NSAssert(syncDateAttribute.length > 0, @"Must provide a value for +managedObjectSyncDateAttribute");
            NSAssert(responseDateKey.length > 0, @"Must provide a value for +responseObjectSyncDateKey");
            NSAssert(responseDateFormat.length > 0, @"Must provide a value for +responseObjectSyncDateFormat");
            NSAssert(predicateFormat.length > 0, @"Must provide a value for +syncPredicateFormat");
            NSAssert(predicateValueIDs.count > 0, @"Must provide a value for +syncPredicateValueIdentifiers");
        }
        
        for (id arrayObject in responseObject) {
            NSManagedObject<JFTransportable>* managedObject;
            
            if (performSync) {
                __block NSString* parsedPredicateFormat = predicateFormat;
                [predicateValueIDs enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    NSString* value = [[self valueFromResponse:arrayObject forKey:obj] stringValue];
                    parsedPredicateFormat = [parsedPredicateFormat stringByReplacingOccurrencesOfString:key withString:value];
                }];
                
                managedObject = [JFDataManager.sharedManager existingObjectWithPredicateFormat:parsedPredicateFormat forEntityName:entityName];
            }
            
            if (!managedObject) {
                managedObject = [JFDataManager.sharedManager insertNewObjectForEntityForName:entityName];
            }
            
            NSDate* remoteUpdateAtDate = [self dateFromString:arrayObject[responseDateKey] withFormat:responseDateFormat];
            NSDate* localUpdatedAtDate = [managedObject valueForKey:syncDateAttribute];
            if (!localUpdatedAtDate || [localUpdatedAtDate compare:remoteUpdateAtDate] == NSOrderedAscending) {
                // Remote object is newer
                [self mapResponseObject:arrayObject toTransportable:&managedObject];
            } else {
                // Local object is newer
            }
            
            [transportableCollection addObject:managedObject];
        }
        
        NSError* error;
        if (![JFDataManager.sharedManager saveContextWithError:&error]) {
            if (error) {
                NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error.localizedDescription);
            }
        }
    } else {
        for (id arrayObject in responseObject) {
            id<JFTransportable> classInstance = [(id)klass new];
            [self mapResponseObject:arrayObject toTransportable:&classInstance];
            [transportableCollection addObject:classInstance];
        }
    }
    
    [_transportable setValue:transportableCollection forKey:property];
}

#pragma mark ----------------------
#pragma mark Nested Key Handling
#pragma mark ----------------------

+ (id)valueFromResponse:(id)response forKey:(NSString *)key
{
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
    return responseValue;
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
#pragma mark Validation
#pragma mark ----------------------

+ (BOOL)isValidMetaClass:(Class)klass
{
    return class_isMetaClass(object_getClass(klass));
}

+ (BOOL)isValidClass:(Class)klass
{
    return [self isValidMetaClass:klass] && [klass conformsToProtocol:@protocol(JFTransportable)];
}

+ (void)assertValidPredicateFormat:(NSString*)format
{
    NSAssert(format.length > 0, @"Must provide a valid string value for +relationshipsPredicateFormat.");
    NSAssert([format rangeOfString:@"="].location != NSNotFound, @"String returned from +relationshipsPredicateFormat must contain an = in order to be a valid relationship predicate format.");
}

#pragma mark ----------------------
#pragma mark Date Formatter
#pragma mark ----------------------

+ (NSDateFormatter*)dateFormatter
{
    static NSDateFormatter* dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [NSDateFormatter new];
    }
    return dateFormatter;
}

+ (NSDate*)dateFromString:(NSString*)dateString withFormat:(NSString*)format
{
    NSDateFormatter* dateFormatter = self.dateFormatter;
    dateFormatter.dateFormat = format;
    return [dateFormatter dateFromString:dateString];
}

@end
