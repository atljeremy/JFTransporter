//
//  Tweet.h
//  JFTransporterExample
//
//  Created by Jeremy Fox on 11/29/14.
//  Copyright (c) 2014 Jeremy Fox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JFTransporter/JFTransportable.h>
#import "Current.h"
#import "Daily.h"

@interface Forecast : NSObject <JFTransportable>

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic, strong) Current* current;
@property (nonatomic, strong) Daily* daily;

// JFTransportable Required Properties
@property (nonatomic, strong) NSURL* URL;
@property (nonatomic, strong) NSString* HTTPMethod;
@property (nonatomic, strong) NSData* HTTPBody;
@property (nonatomic, strong) NSDictionary* HTTPHeaderFields;

- (id)initWithWithLatitude:(double)latitude andLongitude:(double)longitude NS_DESIGNATED_INITIALIZER;

@end
