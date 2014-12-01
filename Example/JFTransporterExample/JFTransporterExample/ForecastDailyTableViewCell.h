//
//  ForecastDailyTableViewCell.h
//  JFTransporterExample
//
//  Created by Jeremy Fox on 12/1/14.
//  Copyright (c) 2014 Jeremy Fox. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Day;

@interface ForecastDailyTableViewCell : UITableViewCell

- (void)configureForDay:(Day*)day;

@property (weak, nonatomic) IBOutlet UILabel *tempHigh;
@property (weak, nonatomic) IBOutlet UILabel *tempLow;
@property (weak, nonatomic) IBOutlet UILabel *summary;
@property (weak, nonatomic) IBOutlet UIImageView *icon;

@end
