//
//  Day.h
//  JFTransporterExample
//
//  Created by Jeremy Fox on 12/1/14.
//  Copyright (c) 2014 Jeremy Fox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JFTransporter/JFTransportable.h>

@interface Day : NSObject <JFTransportable>

@property (nonatomic, strong) NSString* apparentTemperatureMax;
@property (nonatomic, strong) NSNumber* apparentTemperatureMaxTime;
@property (nonatomic, strong) NSString* apparentTemperatureMin;
@property (nonatomic, strong) NSNumber* apparentTemperatureMinTime;
@property (nonatomic, strong) NSString* cloudCover;
@property (nonatomic, strong) NSString* dewPoint;
@property (nonatomic, strong) NSString* humidity;
@property (nonatomic, strong) NSString* icon;
@property (nonatomic, strong) NSString* moonPhase;
@property (nonatomic, strong) NSString* ozone;
@property (nonatomic, strong) NSNumber* precipIntensity;
@property (nonatomic, strong) NSNumber* precipIntensityMax;
@property (nonatomic, strong) NSNumber* precipProbability;
@property (nonatomic, strong) NSString* pressure;
@property (nonatomic, strong) NSString* summary;
@property (nonatomic, strong) NSNumber* sunriseTime;
@property (nonatomic, strong) NSNumber* sunsetTime;
@property (nonatomic, strong) NSNumber* temperatureMax;
@property (nonatomic, strong) NSNumber* temperatureMaxTime;
@property (nonatomic, strong) NSNumber* temperatureMin;
@property (nonatomic, strong) NSNumber* temperatureMinTime;
@property (nonatomic, strong) NSNumber* time;
@property (nonatomic, strong) NSString* visibility;
@property (nonatomic, strong) NSNumber* windBearing;
@property (nonatomic, strong) NSString* windSpeed;

// JFTransportable Required Properties
@property (nonatomic, strong) NSURL* URL;
@property (nonatomic, strong) NSString* HTTPMethod;
@property (nonatomic, strong) NSData* HTTPBody;
@property (nonatomic, strong) NSDictionary* HTTPHeaderFields;

@end
