//
//  ForecastDailyTableViewCell.m
//  JFTransporterExample
//
//  Created by Jeremy Fox on 12/1/14.
//  Copyright (c) 2014 Jeremy Fox. All rights reserved.
//

#import "ForecastDailyTableViewCell.h"
#import "Day.h"

@implementation ForecastDailyTableViewCell

- (void)configureForDay:(Day*)day
{
    self.tempHigh.text = nil;
    self.tempLow.text  = nil;
    self.summary.text  = nil;
    self.icon.image    = nil;

    self.tempHigh.text = [NSString stringWithFormat:@"%li\u00B0", (long)day.temperatureMax.integerValue];
    self.tempLow.text  = [NSString stringWithFormat:@"%li\u00B0", (long)day.temperatureMin.integerValue];
    self.summary.text  = day.summary;
    self.icon.image    = [UIImage imageNamed:day.icon];
}

@end
