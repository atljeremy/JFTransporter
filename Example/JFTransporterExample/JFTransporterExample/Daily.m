//
//  Daily.m
//  JFTransporterExample
//
//  Created by Jeremy Fox on 12/1/14.
//  Copyright (c) 2014 Jeremy Fox. All rights reserved.
//

#import "Daily.h"
#import "Day.h"

@implementation Daily

- (NSDictionary*)responseToObjectModelMapping
{
    return @{@"data": JFObjectModelMappingObjectArray([Day class], @"days")};
}

@end
