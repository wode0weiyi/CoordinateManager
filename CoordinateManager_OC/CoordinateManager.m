 //
//  CoordinateManager.m
//  Clue
//
//  Created by 王璇 on 15/9/23.
//  Copyright (c) 2015年 maomao. All rights reserved.
//

#import "CoordinateManager.h"

//     static final String BAIDU_LBS_TYPE = "bd09ll";

static double a = 6378245.0;
static double ee = 0.00669342162296594323;

/**
 * 各地图API坐标系统比较与转换;
 * WGS84坐标系：即地球坐标系，国际上通用的坐标系。设备一般包含GPS芯片或者北斗芯片获取的经纬度为WGS84地理坐标系,
 * 谷歌地图采用的是WGS84地理坐标系（中国范围除外）;
 * GCJ02坐标系：即火星坐标系，是由中国国家测绘局制订的地理信息系统的坐标系统。由WGS84坐标系经加密后的坐标系。
 * 谷歌中国地图和搜搜中国地图采用的是GCJ02地理坐标系; BD09坐标系：即百度坐标系，GCJ02坐标系经加密后的坐标系;
 * 搜狗坐标系、图吧坐标系等，估计也是在GCJ02基础上加密而成的。 chenhua
 */
@implementation CoordinateManager

/**
 * 84 to 火星坐标系 (GCJ-02) World Geodetic System ==> Mars Geodetic System
 *
 * @param lat
 * @param lon
 * @return
 */
CLLocationCoordinate2D * gps84_To_Gcj02(double lat, double lon) {
    if (outOfChina(lat, lon)) {
        return nil;
    }
    double dLat = transformLat(lon - 105.0, lat - 35.0);
    double dLon = transformLon(lon - 105.0, lat - 35.0);
    double radLat = lat / 180.0 * M_PI;
    double magic = sin(radLat);
    magic = 1 - ee * magic * magic;
    double sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * M_PI);
    dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * M_PI);
    double mgLat = lat + dLat;
    double mgLon = lon + dLon;
    
    CLLocationCoordinate2D *gps=malloc(sizeof(CLLocationCoordinate2D));
    gps->latitude=mgLat;
    gps->longitude=mgLon;
    
    return gps;
}
    
/**
 *
 * 火星坐标系 (GCJ-02) to 84
 * 
 * @param lon 
 * @param lat 
 * @return
 * 
 */
CLLocationCoordinate2D * gcj_To_Gps84(double lat, double lon) {
    CLLocationCoordinate2D *gps = transform(lat, lon);
    double lontitude = lon * 2 - gps->longitude;
    double latitude = lat * 2 - gps->latitude;
    
    CLLocationCoordinate2D *location=malloc(sizeof(CLLocationCoordinate2D));
    location->longitude=lontitude;
    location->latitude=latitude;
    
    free(gps);
    return location;
}
    
/**
 * 火星坐标系 (GCJ-02) 与百度坐标系 (BD-09) 的转换算法 将 GCJ-02 坐标转换成 BD-09 坐标
 *
 * @param gg_lat
 * @param gg_lon
 */
CLLocationCoordinate2D * gcj02_To_Bd09(double gg_lat, double gg_lon) {
    double x = gg_lon, y = gg_lat;
    double z = sqrt(x * x + y * y) + 0.00002 * sin(y * M_PI);
    double theta = atan2(y, x) + 0.000003 * cos(x * M_PI);
    double bd_lon = z *cos(theta) + 0.0065;
    double bd_lat = z * sin(theta) + 0.006;
    
    CLLocationCoordinate2D *gps=malloc(sizeof(CLLocationCoordinate2D));
    gps->latitude=bd_lat;
    gps->longitude=bd_lon;
    return gps;
}
    
/**
 * 
 * 火星坐标系 (GCJ-02) 与百度坐标系 (BD-09) 的转换算法 
 * 
 * 将 BD-09 坐标转换成GCJ-02 坐标 
 * 
 * @param
 * bd_lat 
 * @param bd_lon 
 * @return
 */
CLLocationCoordinate2D * bd09_To_Gcj02(double bd_lat, double bd_lon) {
    double x = bd_lon - 0.0065, y = bd_lat - 0.006;
    double z = sqrt(x * x + y * y) - 0.00002 * sin(y * M_PI);
    double theta = atan2(y, x) - 0.000003 * cos(x * M_PI);
    double gg_lon = z * cos(theta);
    double gg_lat = z * sin(theta);
    
    CLLocationCoordinate2D *gps=malloc(sizeof(CLLocationCoordinate2D));
    gps->latitude=gg_lat;
    gps->longitude=gg_lon;
    return gps;
}
    
bool outOfChina(double lat, double lon) {
    if (lon < 72.004 || lon > 137.8347)
        return true;
    if (lat < 0.8293 || lat > 55.8271)
        return true;
    return false;
}

CLLocationCoordinate2D * transform(double lat, double lon) {
    if (outOfChina(lat, lon)) {
        CLLocationCoordinate2D *gps=malloc(sizeof(CLLocationCoordinate2D));
        gps->latitude=lat;
        gps->longitude=lon;
        return gps;
    }
    
    double dLat = transformLat(lon - 105.0, lat - 35.0);
    double dLon = transformLon(lon - 105.0, lat - 35.0);
    double radLat = lat / 180.0 * M_PI;
    double magic = sin(radLat);
    magic = 1 - ee * magic * magic;
    double sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * M_PI);
    dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * M_PI);
    double mgLat = lat + dLat;
    double mgLon = lon + dLon;
    
    CLLocationCoordinate2D *gps=malloc(sizeof(CLLocationCoordinate2D));
    gps->latitude=mgLat;
    gps->longitude=mgLon;
    return gps;
}

double transformLat(double x, double y) {
    double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y
    + 0.2 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * M_PI) + 40.0 * sin(y / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * M_PI) + 320 * sin(y * M_PI / 30.0)) * 2.0 / 3.0;
    return ret;
}

double transformLon(double x, double y) {
    double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1
    * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * M_PI) + 40.0 * sin(x / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 * M_PI) + 300.0 * sin(x / 30.0 * M_PI)) * 2.0 / 3.0;
    return ret;
}

/**
 * (BD-09)-->84
 * @param bd_lat
 * @param bd_lon
 * @return
 */
CLLocationCoordinate2D * bd09_To_Gps84(double bd_lat, double bd_lon) {
    
    CLLocationCoordinate2D *gcj02 = bd09_To_Gcj02(bd_lat, bd_lon);
    CLLocationCoordinate2D *map84 = gcj_To_Gps84(gcj02->latitude,gcj02->longitude);
    
    free(gcj02);
    return map84;
}

/**
 * 84-->(BD-09)
 * @param 84_lat
 * @param 84_lon
 * @return
 */
CLLocationCoordinate2D * gps84_To_Bd09(double bd_lat, double bd_lon) {
    
    CLLocationCoordinate2D *gcj02 = gps84_To_Gcj02(bd_lat, bd_lon);
    CLLocationCoordinate2D *bd09 = gcj02_To_Bd09(gcj02->latitude,gcj02->longitude);
    free(gcj02);
    return bd09;
}

+ (CLLocationCoordinate2D) bd09_To_Gps84:(double)bd_lat :(double)bd_lon{
    CLLocationCoordinate2D *gps = bd09_To_Gps84(bd_lat, bd_lon);
    CLLocationCoordinate2D location;
    location.latitude=gps->latitude;
    location.longitude=gps->longitude;
    
    free(gps);
    return location;
}

+ (CLLocationCoordinate2D) gps84_To_Bd09:(double)gps_lat :(double)gps_lon{
    CLLocationCoordinate2D *bd = gps84_To_Bd09(gps_lat, gps_lon);
    CLLocationCoordinate2D location;
    location.latitude=bd->latitude;
    location.longitude=bd->longitude;
    
    free(bd);
    return location;
}


@end
