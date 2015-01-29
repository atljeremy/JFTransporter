//
//  JFTransportableResponse.m
//  JFTransporter
//
//  Created by Jeremy Fox on 1/26/15.
//  Copyright (c) 2015 Jeremy Fox. All rights reserved.
//

#import "JFURLResponse.h"
#import "JFTransporterConstants.h"

@implementation JFURLResponse

- (instancetype)initWithHTTPURLResponse:(NSHTTPURLResponse*)HTTPURLResponse
{
    return [super initWithURL:HTTPURLResponse.URL statusCode:HTTPURLResponse.statusCode HTTPVersion:@"HTTP/1.1" headerFields:HTTPURLResponse.allHeaderFields];
}

+ (instancetype)responseFromHTTPURLResponse:(NSHTTPURLResponse*)HTTPURLResponse
{
    return [[self alloc] initWithHTTPURLResponse:HTTPURLResponse];
}

- (NSString*)description
{
    NSString* description = [NSString stringWithFormat:@" HTTPResonse: %@ \n data.length: %li \n acceptableStatusCodeRange: %li - %li", self, self.data.length, self.acceptableStatusCodeRange.beginningCode, self.acceptableStatusCodeRange.endingCode];
    return description;
}

#pragma mark ----------------------
#pragma mark Getters
#pragma mark ----------------------

- (id<NSObject>)JSONObject
{
    NSError* error;
    _JSONObject = [NSJSONSerialization JSONObjectWithData:self.data options:kNilOptions error:&error];
    self.error = error;
    return _JSONObject;
}

#pragma mark ----------------------
#pragma mark Response Validation
#pragma mark ----------------------

- (BOOL)hasAcceptableStatusCode
{
    NSString* message = @"acceptableStatusCodeRange has not been set with a valid HTTPStatusCodeRange. Use HTTPStatusCodeRangeMake to create a valid HTTPStatusCodeRange and assign it to the JFTransportableResponse.acceptableStatusCodeRange property before calling hasAcceptableStatusCode";
    NSUInteger beginningStatusCode = self.acceptableStatusCodeRange.beginningCode;
    NSUInteger endingStatusCode = self.acceptableStatusCodeRange.endingCode;
    NSAssert(beginningStatusCode >= 100 && beginningStatusCode < 600, message);
    NSAssert(endingStatusCode >= 100 && endingStatusCode < 600, message);
    
    return HTTPStatusCodeWithinRange(self.statusCode, self.acceptableStatusCodeRange);
}

@end
