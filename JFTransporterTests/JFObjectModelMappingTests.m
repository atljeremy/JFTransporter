//
//  JFObjectModelMappingTests.m
//  JFTransporter
//
//  Created by Jeremy Fox on 12/1/14.
//  Copyright (c) 2014 Jeremy Fox. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "JFObjectModelMapping.h"
#import "JFTransportable.h"
@import CoreData;

@interface Day : NSObject <JFTransportable>

@property (nonatomic, strong) NSNumber* temperatureMax;
@property (nonatomic, strong) NSNumber* temperatureMin;

@property (nonatomic, strong) NSURL* URL;
@property (nonatomic, strong) NSString* HTTPMethod;
@property (nonatomic, strong) NSData* HTTPBody;
@property (nonatomic, strong) NSDictionary* HTTPHeaderFields;
@end

@implementation Day

- (NSDictionary*)responseToObjectModelMapping
{
    return @{@"temperatureMax" : @"temperatureMax",
             @"temperatureMin" : @"temperatureMin"};
}

@end

/***********************************************************/

@interface Daily : NSObject <JFTransportable>

@property (nonatomic, strong) NSArray/*<Day>*/* days;

@property (nonatomic, strong) NSURL* URL;
@property (nonatomic, strong) NSString* HTTPMethod;
@property (nonatomic, strong) NSData* HTTPBody;
@property (nonatomic, strong) NSDictionary* HTTPHeaderFields;

@end

@implementation Daily

- (NSDictionary*)responseToObjectModelMapping
{
    return @{@"data": JFObjectModelMappingObjectArray([Day class], @"days")};
}

@end

/***********************************************************/

@interface Current : Day <JFTransportable>

@property (nonatomic, copy) NSString* temperature;

@end

@implementation Current

- (NSDictionary*)responseToObjectModelMapping
{
    NSMutableDictionary* mapping = [[super responseToObjectModelMapping] mutableCopy];
    [mapping addEntriesFromDictionary:@{@"temperature": @"temperature"}];
    
    return mapping;
}

@end

/***********************************************************/

@interface TestNestedTransportable : NSObject <JFTransportable>

@property (nonatomic, strong) NSArray* array;

@property (nonatomic, strong) NSURL* URL;
@property (nonatomic, strong) NSString* HTTPMethod;
@property (nonatomic, strong) NSData* HTTPBody;
@property (nonatomic, strong) NSDictionary* HTTPHeaderFields;
@end

@implementation TestNestedTransportable

- (NSDictionary*)responseToObjectModelMapping
{
    return @{@"daily[data]": JFObjectModelMappingObjectArray([Day class], @"array")};
}

@end

/***********************************************************/

@interface TestNestedTransportableTwo : NSObject <JFTransportable>

@property (nonatomic, strong) NSArray* array;

@property (nonatomic, strong) NSURL* URL;
@property (nonatomic, strong) NSString* HTTPMethod;
@property (nonatomic, strong) NSData* HTTPBody;
@property (nonatomic, strong) NSDictionary* HTTPHeaderFields;
@end

@implementation TestNestedTransportableTwo

- (NSDictionary*)responseToObjectModelMapping
{
    return @{@"thisisalongkey[thisisanotherlongkey][yetanotherlongeykey]": JFObjectModelMappingObjectArray([Day class], @"array")};
}

@end

/***********************************************************/

@interface TestTransportable : NSObject <JFTransportable>

@property (nonatomic, strong) Current* current;
@property (nonatomic, strong) Daily* daily;

@property (nonatomic, strong) NSURL* URL;
@property (nonatomic, strong) NSString* HTTPMethod;
@property (nonatomic, strong) NSData* HTTPBody;
@property (nonatomic, strong) NSDictionary* HTTPHeaderFields;
@end

@implementation TestTransportable

- (NSDictionary*)responseToObjectModelMapping
{
    return @{@"currently": JFObjectModelMappingObjectDictionary([Current class], @"current"),
             @"daily": JFObjectModelMappingObjectDictionary([Daily class], @"daily")};
}

@end

/***********************************************************/

@interface JFObjectModelMappingTests : XCTestCase
@property (nonatomic, strong) NSDictionary* response;
@property (nonatomic, strong) TestNestedTransportable* nestedTransportable;
@property (nonatomic, strong) TestNestedTransportableTwo* nestedTransportableTwo;
@property (nonatomic, strong) TestTransportable* transportable;
@end

@implementation JFObjectModelMappingTests

- (void)setUp {
    [super setUp];
    self.response = @{@"currently": @{@"temperature": @55.96},
                      @"daily": @{@"data": @[@{@"temperatureMax": @86.45,
                                               @"temperatureMin": @45.67},
                                             @{@"temperatureMax": @98.32,
                                               @"temperatureMin": @22.11}]},
                      @"thisisalongkey": @{@"thisisanotherlongkey": @{@"yetanotherlongeykey": @[@{@"temperatureMax": @12345.00,
                                                                                                  @"temperatureMin": @54321.00}]}}};
    TestNestedTransportable* nestedTransportable = [TestNestedTransportable new];
    [JFObjectModelMapping mapResponseObject:self.response toTransportable:&nestedTransportable];
    self.nestedTransportable = nestedTransportable;
    
    TestNestedTransportableTwo* nestedTransportableTwo = [TestNestedTransportableTwo new];
    [JFObjectModelMapping mapResponseObject:self.response toTransportable:&nestedTransportableTwo];
    self.nestedTransportableTwo = nestedTransportableTwo;
    
    TestTransportable* transportable = [TestTransportable new];
    [JFObjectModelMapping mapResponseObject:self.response toTransportable:&transportable];
    self.transportable = transportable;
}

- (void)testMappingMapsToProperDaysArrayObject {
    XCTAssertTrue(self.transportable.daily.days.count == 2, @"Nested response mapping should map to a valid object");
}

- (void)testMappingMapsToProperCurrentObject {
    XCTAssertEqual(self.transportable.current.class, [Current class], @"Nested response mapping should map to a valid Current object");
}

- (void)testMappingMapsToProperDailyObject {
    XCTAssertEqual(self.transportable.daily.class, [Daily class], @"Nested response mapping should map to a valid Daily object");
}

- (void)testMappingMapsToProperDailyDayObject {
    XCTAssertEqual(((Day*)self.transportable.daily.days.firstObject).class, [Day class], @"Nested response mapping should map to a valid Daily->Day object");
}

// nested mapping tests

- (void)testNestedMappingMapsToProperObject {
    XCTAssertTrue(self.nestedTransportable.array.count == 2, @"Nested response mapping should map to a valid object");
}

- (void)testNestedMappingMapsToDayObject {
    XCTAssertEqual(((Day*)self.nestedTransportable.array.firstObject).class, [Day class], @"Nested response mapping should map to Day object");
}

- (void)testNestedMappingMapsToProperObjectValueMax {
    Day* day = [self.nestedTransportable.array firstObject];
    XCTAssertEqual(day.temperatureMax.doubleValue, 86.45, @"Nested response mapping should map to valid max value");
}

- (void)testNestedMappingMapsToProperObjectValueMin {
    Day* day = [self.nestedTransportable.array lastObject];
    XCTAssertEqual(day.temperatureMin.doubleValue, 22.11, @"Nested response mapping should map to valid min value");
}

// deeply nested mapping tests

- (void)testDeeplyNestedMappingMapsToProperObject {
    XCTAssertTrue(self.nestedTransportableTwo.array.count == 1, @"Nested response mapping should map to a valid object");
}

- (void)testDeeplyNestedMappingMapsToDayObject {
    XCTAssertEqual(((Day*)self.nestedTransportableTwo.array.firstObject).class, [Day class], @"Nested response mapping should map to Day object");
}

- (void)testDeeplyNestedMappingMapsToProperObjectValueMax {
    Day* day = [self.nestedTransportableTwo.array firstObject];
    XCTAssertEqual(day.temperatureMax.doubleValue, 12345.00, @"Nested response mapping should map to valid max value");
}

- (void)testDeeplyNestedMappingMapsToProperObjectValueMin {
    Day* day = [self.nestedTransportableTwo.array firstObject];
    XCTAssertEqual(day.temperatureMin.doubleValue, 54321.00, @"Nested response mapping should map to valid min value");
}

// mapping performance tests

- (void)testNestedObjectMappingPerformanceTwo {
    __block TestNestedTransportableTwo* transportable = [TestNestedTransportableTwo new];
    [self measureBlock:^{
        [JFObjectModelMapping mapResponseObject:self.response toTransportable:&transportable];
    }];
}

- (void)testNestedObjectMappingPerformance {
    __block TestNestedTransportable* transportable = [TestNestedTransportable new];
    [self measureBlock:^{
        [JFObjectModelMapping mapResponseObject:self.response toTransportable:&transportable];
    }];
}

- (void)testObjectMappingPerformance {
    __block TestTransportable* transportable = [TestTransportable new];
    [self measureBlock:^{
        [JFObjectModelMapping mapResponseObject:self.response toTransportable:&transportable];
    }];
}

@end