//
//  CoordinateManager.h
//  Clue
//
//  Created by 王璇 on 15/9/23.
//  Copyright (c) 2015年 maomao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface CoordinateManager : NSObject

/**
 *百度坐标系转地球坐标系
 */
+ (CLLocationCoordinate2D) bd09_To_Gps84:(double)bd_lat :(double)bd_lon;
/**
 *地球坐标系转百度坐标系
 */
+ (CLLocationCoordinate2D) gps84_To_Bd09:(double)gps_lat :(double)gps_lon;
@end
