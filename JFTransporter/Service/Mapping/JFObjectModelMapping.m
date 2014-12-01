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
        [key enumerateSubstringsInRange:NSMakeRange(0, key.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
            NSLog(@"string");
        }];
    }
    
    if (keys && keys.count > 0) {
        retVal = key;
    }
    
    return retVal;
}

@end
