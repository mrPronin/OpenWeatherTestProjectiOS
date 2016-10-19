//
//  OpenWeather.m
//  OpenWeather
//
//  Created by Aleksandr Pronin on 10/19/16.
//  Copyright © 2016 Aleksandr Pronin. All rights reserved.
//

#import "OpenWeather.h"

@implementation OpenWeather

static NSString *APIKey = @"b51965c96225c8c134fde6e12f240d7c";
//0475c7d8d5d906972e51a3def92f5386
static NSString *baseURL = @"http://api.openweathermap.org/data/2.5/forecast/";

static NSURLSession *session = nil;



+ (instancetype)sharedInstance {
    static dispatch_once_t pred;
    static id shared = nil;
    dispatch_once(&pred, ^{
        shared = [[super alloc] init];
    });
    return shared;
}

- (void)getWeatherForLatitude:(float)latitude longtitude:(float)longtitude result:(void(^)(NSDictionary *requestResult, NSError *error))result {
    if (!session) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        [config setAllowsCellularAccess:YES];
        session = [NSURLSession sessionWithConfiguration:config];
    }

    NSString *urlString = [baseURL stringByAppendingFormat:@"daily?lat=%f&lon=%f&cnt=%i", latitude, longtitude, 7];
    urlString = [urlString stringByAppendingFormat:@"&APPID=%@", APIKey];
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                    initWithURL:[NSURL URLWithString:urlString]
                                    cachePolicy:NSURLRequestReloadIgnoringCacheData
                                    timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (!error) {
                                                        NSError *error;
                                                        NSDictionary *dict = [self deserializeJSON:data andError:&error];
                                                        result(dict, error);
                                                    }
                                                }];
    [dataTask resume];
}



- (id)deserializeJSON:(NSData *)jsonData andError:(NSError **)jsonError
{
    if (jsonData == nil) {
        return nil;
    }
    
    id deserializedJSON = nil;
    // Now try to deserialize the JSON object into a dictionary
    NSError *error = nil;
    
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                    options:NSJSONReadingAllowFragments
                                                      error:&error];
    if (jsonObject != nil && error == nil) {
        if ([jsonObject isKindOfClass:[NSDictionary class]])
        {
            deserializedJSON = (NSDictionary *)jsonObject;
            return deserializedJSON;
            
        } else if ([jsonObject isKindOfClass:[NSArray class]])  {
            deserializedJSON = (NSArray *)jsonObject;
            return deserializedJSON;
            
        } else  {
            NSLog(@"[%@ %@] -- Deserializing JSON data error. Json object is not array or dictionary!", [self class], NSStringFromSelector(_cmd));
            return nil;
        }
    } else if (error != nil)  {
        *jsonError = error;
        return nil;
    }
    return nil;
}

@end
