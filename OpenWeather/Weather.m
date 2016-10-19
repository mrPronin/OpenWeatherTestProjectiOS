//
//  Weather.m
//  OpenWeather
//
//  Created by Aleksandr Pronin on 10/19/16.
//  Copyright © 2016 Aleksandr Pronin. All rights reserved.
//

#import "Weather.h"

@implementation Weather

- (instancetype)initWith:(NSDate*)date temperature:(float)temperature title:(NSString*)title {
    if (self == [super init]) {
        self.date = date;
        self.temperature = temperature;
        self.title = title;
    }
    return self;
}

@end
