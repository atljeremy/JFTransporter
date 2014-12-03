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

@interface TestTransportable : NSObject <JFTransportable>

@property (nonatomic, strong) NSArray* array;

@property (nonatomic, strong) NSURL* URL;
@property (nonatomic, strong) NSString* HTTPMethod;
@property (nonatomic, strong) NSData* HTTPBody;
@property (nonatomic, strong) NSDictionary* HTTPHeaderFields;
@end

@implementation TestTransportable

- (NSDictionary*)responseToObjectModelMapping
{
    return @{@"daily[data]": JFObjectModelMappingObjectArray([Day class], @"array")};
}

@end

/***********************************************************/

@interface JFObjectModelMappingTests : XCTestCase
@property (nonatomic, strong) NSDictionary* response;
@end

@implementation JFObjectModelMappingTests

- (void)setUp {
    [super setUp];
    self.response = @{@"currently": @{@"temperature": @(55.96)},
                      @"daily": @{@"data": @[@{@"temperatureMax": @(86.45)}, @{@"temperatureMin": @(45.67)}]}};
}

- (void)testNestedMappingMapsToProperObject {
    TestTransportable* transportable = [TestTransportable new];
    [JFObjectModelMapping mapResponseObject:self.response toTransportable:&transportable];
    XCTAssert(transportable.array.count > 0, @"Nested response mapping should map to a valid object");
}

//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end