//
//  ViewController.m
//  JFTransporterExample
//
//  Created by Jeremy Fox on 11/29/14.
//  Copyright (c) 2014 Jeremy Fox. All rights reserved.
//

#import "ViewController.h"
#import "Forecast.h"
#import <JFTransporter/JFTransporter.h>
#import "ForecastCurrentTableViewCell.h"
#import "ForecastDailyTableViewCell.h"

@interface ViewController ()
@property (nonatomic, strong) Forecast* forecast;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorColor = [UIColor darkGrayColor];
    Forecast* forecast = [[Forecast alloc] initWithWithLatitude:33.7550 andLongitude:-84.3900];
    [[JFTransporter defaultTransporter] GETTransportable:forecast withCompletionHandler:^(id<JFTransportable> transportable, NSError *error) {
        if (transportable && !error) {
            self.forecast = transportable;
            [self.tableView reloadData];
        }
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 100;
    } else {
        return 60;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.forecast.daily.days.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* returnCell;
    if (indexPath.row == 0) {
        ForecastCurrentTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"ForecastCurrentTableViewCell" forIndexPath:indexPath];
        [cell configureWithCurrentForecast:self.forecast.current];
        returnCell = cell;
    } else {
        ForecastDailyTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"ForecastDailyTableViewCell" forIndexPath:indexPath];
        [cell configureForDay:self.forecast.daily.days[indexPath.row - 1]];
        returnCell = cell;
    }
    
    return returnCell;
}

@end
