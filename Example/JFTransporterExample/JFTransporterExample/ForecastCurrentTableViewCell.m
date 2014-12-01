//
//  ForecastCurrentTableViewCell.m
//  JFTransporterExample
//
//  Created by Jeremy Fox on 12/1/14.
//  Copyright (c) 2014 Jeremy Fox. All rights reserved.
//

#import "ForecastCurrentTableViewCell.h"
#import "Current.h"

@implementation ForecastCurrentTableViewCell

- (void)configureWithCurrentForecast:(Current*)current
{
    self.currentSummary.text = nil;
    self.currentTemp.text    = nil;
    self.currentIcon.image   = nil;
    
    self.currentSummary.text = current.summary;
    self.currentTemp.text    = [NSString stringWithFormat:@"%li\u00B0", (long)current.temperature.integerValue];
    self.currentIcon.image   = [UIImage imageNamed:current.icon];
}

@end
