//
//  ViewController.m
//  OpenWeather
//
//  Created by Aleksandr Pronin on 10/19/16.
//  Copyright © 2016 Aleksandr Pronin. All rights reserved.
//

#import "ViewController.h"
#import "OpenWeather.h"
#import "Weather.h"
#import "WeatherTableViewCell.h"

#import <CoreLocation/CoreLocation.h>

@interface ViewController () <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UILabel *tempLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *todayImage;

@property (strong, nonatomic) NSMutableArray *dataSource;

@end

@implementation ViewController {
    CLLocationManager *locationManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.allowsBackgroundLocationUpdates = false;
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    [locationManager requestWhenInUseAuthorization];
    [locationManager requestLocation];
    self.dataSource = [NSMutableArray new];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = @"weatherCell";
    WeatherTableViewCell *weatherCell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    Weather *weather = self.dataSource[indexPath.row];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd.MM.yyyy"];
    weatherCell.dateLabel.text = [formatter stringFromDate:weather.date];
    weatherCell.tempLabel.text = [NSString stringWithFormat:@"%.01f°", weather.temperature];
    return weatherCell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (error) {
        NSLog(@"Error %s, %@", __PRETTY_FUNCTION__, error.description);
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CLLocation *currentLocation = [locations firstObject];

        [[OpenWeather sharedInstance] getWeatherForLatitude:currentLocation.coordinate.latitude longtitude:currentLocation.coordinate.longitude result:^(NSDictionary *requestResult, NSError *error) {
            
            NSDictionary *cityInfo = requestResult[@"city"];
            NSArray *days = requestResult[@"list"];
            
            for (int i = 0; i < days.count; i++) {
                NSDictionary *day = days[i];
                NSNumber *unixDate = day[@"dt"];
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:unixDate.integerValue];
                
                NSDictionary *temp = day[@"temp"];
                NSNumber *dayTemp = temp[@"day"];
                
                CGFloat temperature = [dayTemp floatValue] - 273.15;
                
                NSArray *weather = day[@"weather"];
                NSDictionary *weatherDictionary = [weather firstObject];
                NSString *weatherTitle = weatherDictionary[@"description"];
                
                NSString *icon = weatherDictionary[@"icon"];
                NSString *string = [NSString stringWithFormat:@"http://openweathermap.org/img/w/%@.png", icon];
                NSData *imageDate = [NSData dataWithContentsOfURL:[NSURL URLWithString:string]];
                
                if (i == 0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.cityLabel.text = cityInfo[@"name"];
                        self.tempLabel.text = [NSString stringWithFormat:@"%.01f°", temperature];
                        self.descriptionLabel.text = weatherTitle.capitalizedString;
                        if (imageDate) {
                            UIImage *image = [UIImage imageWithData:imageDate];
                            self.todayImage.image = image;
                        }
                    });
                    continue;
                }
                Weather *weatherInstance = [[Weather alloc] initWith:date temperature: temperature title:weatherTitle];
                
                [self.dataSource addObject:weatherInstance];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
    });

}

@end
