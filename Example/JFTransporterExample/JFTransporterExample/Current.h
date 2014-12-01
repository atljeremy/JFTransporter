//
//  Current.h
//  JFTransporterExample
//
//  Created by Jeremy Fox on 12/1/14.
//  Copyright (c) 2014 Jeremy Fox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JFTransporter/JFTransportable.h>
#import "Day.h"

@interface Current : Day <JFTransportable>

@property (nonatomic, copy) NSString* apparentTemperature;
@property (nonatomic, copy) NSNumber* nearestStormBearing;
@property (nonatomic, copy) NSNumber* nearestStormDistance;
@property (nonatomic, copy) NSString* temperature;

@end
