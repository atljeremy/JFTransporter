//
//  Tweet.m
//  JFTransporterExample
//
//  Created by Jeremy Fox on 11/29/14.
//  Copyright (c) 2014 Jeremy Fox. All rights reserved.
//

#import "Forecast.h"

// URL Format: https://api.forecast.io/forecast/APIKEY/LATITUDE,LONGITUDE
static NSString* const kForecastAPIURLString = @"https://api.forecast.io/forecast/018524e6ba1870dc2c7356d98d9b9b40";

@implementation Forecast

- (id)initWithWithLatitude:(double)latitude andLongitude:(double)longitude
{
    if (self = [super init]) {
        _latitude = latitude;
        _longitude = longitude;
    }
    return self;
}

#pragma mark ----------------------
#pragma mark JFTransportable
#pragma mark ----------------------

- (NSURL*)GETURL
{
    NSURL* URL = [NSURL URLWithString:kForecastAPIURLString];
    URL = [URL URLByAppendingPathComponent:[NSString stringWithFormat:@"%f,%f", self.latitude, self.longitude]];
    return URL;
}

- (NSDictionary*)responseToObjectModelMapping
{
    return @{@"currently": JFObjectModelMappingObjectDictionary([Current class], @"current"),
             @"daily": JFObjectModelMappingObjectDictionary([Daily class], @"daily")};
}

@end
