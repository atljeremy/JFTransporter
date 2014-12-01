//
//  ForecastCurrentTableViewCell.h
//  JFTransporterExample
//
//  Created by Jeremy Fox on 12/1/14.
//  Copyright (c) 2014 Jeremy Fox. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Current;

@interface ForecastCurrentTableViewCell : UITableViewCell

- (void)configureWithCurrentForecast:(Current*)current;

@property (weak, nonatomic) IBOutlet UILabel *currentTemp;
@property (weak, nonatomic) IBOutlet UILabel *currentSummary;
@property (weak, nonatomic) IBOutlet UIImageView *currentIcon;

@end
