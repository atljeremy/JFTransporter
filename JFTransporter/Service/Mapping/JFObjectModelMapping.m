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

NSString* const kJFObjectModelMappingPropertyKey = @"modelProperty";
NSString* const kJFObjectModelMappingObjectKey   = @"object";
static NSInteger const kJFObjectModelMappingArrayObjectIndex   = 0;
static NSInteger const kJFObjectModelMappingArrayPropertyIndex = 1;

NSDictionary* JFObjectModelMappingObjectDictionary(Class __CLASS__, NSString* __PROPERTY__) {
    return @{kJFObjectModelMappingObjectKey: __CLASS__, kJFObjectModelMappingPropertyKey: __PROPERTY__};
}

NSArray* JFObjectModelMappingObjectArray(Class __CLASS__, NSString* __PROPERTY__) {
    return @[__CLASS__, __PROPERTY__];
}

@implementation JFObjectModelMapping

+ (void)mapResponseObject:(id<NSObject>)response toTransportable:(id<JFTransportable>*)transportable
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
        
        if ([value isKindOfClass:[NSDictionary class]]) {
            NSString* property = value[kJFObjectModelMappingPropertyKey];
            id klass = value[kJFObjectModelMappingObjectKey];
            if (class_isMetaClass(object_getClass(klass))) {
                if (class_conformsToProtocol(klass, @protocol(JFTransportable))) {
                    id<JFTransportable> classInstance = [klass new];
                    [self mapResponseObject:responseValue toTransportable:&classInstance];
                    [_transportable setValue:classInstance forKey:property];
                } else {
                    NSString* reason = @"Classes added to the object mapping dictionary returned by -responseToObjectModelMapping must conform to the JFTransportable protocol.";
                    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:@{NSLocalizedDescriptionKey: reason}];
                }
            }
        } else if ([value isKindOfClass:[NSArray class]] && ((NSArray*)value).count == 2) {
            NSArray* _value = (NSArray*)value;
            NSString* property = _value[kJFObjectModelMappingArrayPropertyIndex];
            id klass = _value[kJFObjectModelMappingArrayObjectIndex];
            if (class_conformsToProtocol(klass, @protocol(JFTransportable))) {
                NSMutableArray* transportableArray = [@[] mutableCopy];
                if ([responseValue isKindOfClass:[NSArray class]]) {
                    for (id arrayObject in (NSArray*)responseValue) {
                        id<JFTransportable> classInstance = [klass new];
                        [self mapResponseObject:arrayObject toTransportable:&classInstance];
                        [transportableArray addObject:classInstance];
                    }
                }
                [_transportable setValue:transportableArray forKey:property];
            } else {
                NSString* reason = @"Classes added to the object mapping dictionary returned by -responseToObjectModelMapping must conform to the JFTransportable protocol.";
                @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:@{NSLocalizedDescriptionKey: reason}];
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

@end
