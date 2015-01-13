//
//  JFObjectModelMapping.m
//  JFTransporter
//
//  Created by Jeremy Fox on 12/1/14.
//  Copyright (c) 2014 Jeremy Fox. All rights reserved.
//

#import "JFObjectModelMapping.h"
#import "JFTransportable.h"
#import "JFDataSynchronizable.h"
#import <objc/runtime.h>
#import "JFDataManager.h"
@import CoreData;

NSString* const kJFObjectModelMappingEntityKey    = @"entityName";
NSString* const kJFObjectModelMappingPropertyKey  = @"modelProperty";
NSString* const kJFObjectModelMappingObjectKey    = @"object";
NSString* const kJFObjectModelMappingDatFormatKey = @"dateFormat";

typedef NS_ENUM(NSInteger, JFObjectModelMappingArrayIndex) {
    JFObjectModelMappingArrayIndexObject,
    JFObjectModelMappingArrayIndexProperty,
    JFObjectModelMappingArrayIndexEntity,
    JFObjectModelMappingArrayIndexCollection,
    JFObjectModelMappingArrayIndexCount // Must always be last to represent the 'array.count'
};

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
    return @{kJFObjectModelMappingDatFormatKey: __DATE_FORMAT__,
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

+ (void)mapResponseObject:(id<NSObject>)response toTransportable:(id<JFTransportable>*)transportable
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
    
    NSError* error;
    if (![JFDataManager.sharedManager saveContextWithError:&error]) {
        if (error) {
            NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        }
    }
}

#pragma mark ----------------------
#pragma mark Dictionary Mapping
#pragma mark ----------------------

+ (void)mapResponseObject:(id)responseObject toTransportable:(NSObject *)_transportable withValuesDictionary:(NSDictionary*)values
{
    NSDictionary* _values = values;
    
    NSString* dateFormat = _values[kJFObjectModelMappingDatFormatKey];
    NSString* property = _values[kJFObjectModelMappingPropertyKey];
    
    if (dateFormat.length > 0 && property.length > 0) {
        NSDate* date = [self dateFromString:responseObject withFormat:dateFormat];
        [_transportable setValue:date forKey:property];
    } else {
        NSString* entityName = _values[kJFObjectModelMappingEntityKey];
        Class klass = _values[kJFObjectModelMappingObjectKey];
        NSAssert([self isValidClass:klass], @"Classes added to the object mapping dictionary returned by -responseToObjectModelMapping must conform to the JFTransportable protocol.");
        if (entityName) {
            NSManagedObject<JFTransportable>* managedObject;
            
            BOOL performSync = NO;
            NSString* syncDateAttribute;
            NSString* syncIdentifier;
            NSString* responseDateKey;
            NSString* responseDateFormat;
            NSString* responseIdentifierKey;
            if ([klass conformsToProtocol:@protocol(JFDataSynchronizable)]) {
                syncDateAttribute       = [klass managedObjectSyncDateAttribute];
                syncIdentifier          = [klass managedObjectSyncIdentifierAttribute];
                responseDateKey         = [klass responseObjectSyncDateKey];
                responseDateFormat      = [klass responseObjectSyncDateFormat];
                responseIdentifierKey   = [klass responseObjectSyncIdentifierKey];
                if ((performSync = [klass shouldSync])) {
                    NSAssert(syncDateAttribute.length > 0, @"Must provide a value for -managedObjectSyncDateAttribute");
                    NSAssert(syncIdentifier.length > 0, @"Must provide a value for -managedObjectSyncIdentifierAttribute");
                    NSAssert(responseDateKey.length > 0, @"Must provide a value for -responseObjectSyncDateKey");
                    NSAssert(responseDateFormat.length > 0, @"Must provide a value for -responseObjectSyncDateFormat");
                    NSAssert(responseIdentifierKey.length > 0, @"Must provide a value for -responseObjectSyncIdentifierKey");
                }
            }
            
            if (performSync) {
                managedObject = [JFDataManager.sharedManager existingObjectWithAttribute:syncIdentifier matchingValue:responseObject[responseIdentifierKey] forEntityName:entityName];
            }
            
            if (!managedObject) {
                managedObject = [JFDataManager.sharedManager insertNewObjectForEntityForName:entityName];
            }
            
            NSDate* remoteUpdateAtDate = [self dateFromString:responseObject[responseDateKey] withFormat:responseDateFormat];
            NSDate* localUpdatedAtDate = [managedObject valueForKey:syncDateAttribute];
            if ([localUpdatedAtDate compare:remoteUpdateAtDate] == NSOrderedAscending) {
                // Remote object is newer
                [self mapResponseObject:responseObject toTransportable:&managedObject];
            } else {
                // Local object is newer
            }
            
            [_transportable setValue:managedObject forKey:property];
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
    NSString* entityName;
    id collection;
    if (_values.count == JFObjectModelMappingArrayIndexCount) {
        entityName = _values[JFObjectModelMappingArrayIndexEntity];
        collection = _values[JFObjectModelMappingArrayIndexCollection];
    }
    NSString* property = _values[JFObjectModelMappingArrayIndexProperty];
    
    Class klass = _values[JFObjectModelMappingArrayIndexObject];
    NSAssert([self isValidClass:klass], @"Classes added to the object mapping dictionary returned by -responseToObjectModelMapping must conform to the JFTransportable protocol.");
    
    id transportableArray = [[collection new] mutableCopy];
    if (entityName) {
        
        BOOL performSync = NO;
        NSString* syncDateAttribute;
        NSString* syncIdentifier;
        NSString* responseDateKey;
        NSString* responseDateFormat;
        NSString* responseIdentifierKey;
        if ([klass conformsToProtocol:@protocol(JFDataSynchronizable)]) {
            syncDateAttribute       = [klass managedObjectSyncDateAttribute];
            syncIdentifier          = [klass managedObjectSyncIdentifierAttribute];
            responseDateKey         = [klass responseObjectSyncDateKey];
            responseDateFormat      = [klass responseObjectSyncDateFormat];
            responseIdentifierKey   = [klass responseObjectSyncIdentifierKey];
            if ((performSync = [klass shouldSync])) {
                NSAssert(syncDateAttribute.length > 0, @"Must provide a value for -managedObjectSyncDateAttribute");
                NSAssert(syncIdentifier.length > 0, @"Must provide a value for -managedObjectSyncIdentifierAttribute");
                NSAssert(responseDateKey.length > 0, @"Must provide a value for -responseObjectSyncDateKey");
                NSAssert(responseDateFormat.length > 0, @"Must provide a value for -responseObjectSyncDateFormat");
                NSAssert(responseIdentifierKey.length > 0, @"Must provide a value for -responseObjectSyncIdentifierKey");
            }
        }
        
        for (id arrayObject in responseObject) {
            NSManagedObject<JFTransportable>* managedObject;
            
            if (performSync) {
                managedObject = [JFDataManager.sharedManager existingObjectWithAttribute:syncIdentifier matchingValue:arrayObject[responseIdentifierKey] forEntityName:entityName];
            }
            
            if (!managedObject) {
                managedObject = [JFDataManager.sharedManager insertNewObjectForEntityForName:entityName];
            }
            
            NSDate* remoteUpdateAtDate = [self dateFromString:arrayObject[responseDateKey] withFormat:responseDateFormat];
            NSDate* localUpdatedAtDate = [managedObject valueForKey:syncDateAttribute];
            if ([localUpdatedAtDate compare:remoteUpdateAtDate] == NSOrderedAscending) {
                // Remote object is newer
                [self mapResponseObject:arrayObject toTransportable:&managedObject];
            } else {
                // Local object is newer
            }
            
            [transportableArray addObject:managedObject];
        }
    } else {
        for (id arrayObject in responseObject) {
            id<JFTransportable> classInstance = [(id)klass new];
            [self mapResponseObject:arrayObject toTransportable:&classInstance];
            [transportableArray addObject:classInstance];
        }
    }
    
    [_transportable setValue:transportableArray forKey:property];
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

+ (BOOL)isValidClass:(Class)klass
{
    return class_isMetaClass(object_getClass(klass)) && class_conformsToProtocol(klass, @protocol(JFTransportable));
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
