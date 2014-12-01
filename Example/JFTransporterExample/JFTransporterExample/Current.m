//
//  Current.m
//  JFTransporterExample
//
//  Created by Jeremy Fox on 12/1/14.
//  Copyright (c) 2014 Jeremy Fox. All rights reserved.
//

#import "Current.h"

@implementation Current

- (NSDictionary*)responseToObjectModelMapping
{
    NSMutableDictionary* mapping = [[super responseToObjectModelMapping] mutableCopy];
    [mapping addEntriesFromDictionary:@{
                                       @"apparentTemperature" : @"apparentTemperature",
                                       @"nearestStormBearing" : @"nearestStormBearing",
                                       @"nearestStormDistance": @"nearestStormDistance",
                                       @"temperature"         : @"temperature",
                                       }];
    
    return mapping;
}

@end
