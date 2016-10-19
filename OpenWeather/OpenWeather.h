//
//  OpenWeather.h
//  OpenWeather
//
//  Created by Aleksandr Pronin on 10/19/16.
//  Copyright © 2016 Aleksandr Pronin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OpenWeather : NSObject

+ (instancetype)sharedInstance;

- (void)getWeatherForLatitude:(float)latitude longtitude:(float)longtitude
                       result:(void(^)(NSDictionary *requestResult, NSError *error))result;
@end
