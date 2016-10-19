//
//  Weather.h
//  OpenWeather
//
//  Created by Aleksandr Pronin on 10/19/16.
//  Copyright © 2016 Aleksandr Pronin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Weather : NSObject

@property (strong, nonatomic) NSDate *date;
@property (assign, nonatomic) float temperature;
@property (strong, nonatomic) NSString *title;

- (instancetype)initWith:(NSDate*)date temperature:(float)temperature title:(NSString*)title;

@end
