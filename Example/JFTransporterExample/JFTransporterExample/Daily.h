//
//  Daily.h
//  JFTransporterExample
//
//  Created by Jeremy Fox on 12/1/14.
//  Copyright (c) 2014 Jeremy Fox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JFTransporter/JFTransportable.h>

@interface Daily : NSObject <JFTransportable>

@property (nonatomic, strong) NSArray/*<Day>*/* days;

// JFTransportable Required Properties
@property (nonatomic, strong) NSURL* URL;
@property (nonatomic, strong) NSString* HTTPMethod;
@property (nonatomic, strong) NSData* HTTPBody;
@property (nonatomic, strong) NSDictionary* HTTPHeaderFields;

@end
