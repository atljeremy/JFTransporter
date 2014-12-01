//
//  Day.m
//  JFTransporterExample
//
//  Created by Jeremy Fox on 12/1/14.
//  Copyright (c) 2014 Jeremy Fox. All rights reserved.
//

#import "Day.h"

@implementation Day

- (NSDictionary*)responseToObjectModelMapping
{
    return @{
             @"apparentTemperatureMax"      : @"apparentTemperatureMax",
             @"apparentTemperatureMaxTime"  : @"apparentTemperatureMaxTime",
             @"apparentTemperatureMin"      : @"apparentTemperatureMin",
             @"apparentTemperatureMinTime"  : @"apparentTemperatureMinTime",
             @"cloudCover"                  : @"cloudCover",
             @"dewPoint"                    : @"dewPoint",
             @"humidity"                    : @"humidity",
             @"icon"                        : @"icon",
             @"ozone"                       : @"ozone",
             @"moonPhase"                   : @"moonPhase",
             @"precipIntensity"             : @"precipIntensity",
             @"precipIntensityMax"          : @"precipIntensityMax",
             @"precipProbability"           : @"precipProbability",
             @"pressure"                    : @"pressure",
             @"sunriseTime"                 : @"sunriseTime",
             @"sunsetTime"                  : @"sunsetTime",
             @"summary"                     : @"summary",
             @"temperatureMax"              : @"temperatureMax",
             @"temperatureMaxTime"          : @"temperatureMaxTime",
             @"temperatureMin"              : @"temperatureMin",
             @"temperatureMinTime"          : @"temperatureMinTime",
             @"time"                        : @"time",
             @"visibility"                  : @"visibility",
             @"windBearing"                 : @"windBearing",
             @"windSpeed"                   : @"windSpeed"
             };
}

@end
