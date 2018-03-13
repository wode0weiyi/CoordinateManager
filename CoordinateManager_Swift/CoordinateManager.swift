//
//  CoordinateManager.swift
//  PingAnTong_WenZhou
//
//  Created by 胡志辉 on 2018/1/11.
//  Copyright © 2018年 maomao. All rights reserved.
//

import UIKit
import CoreLocation
/**
 * 各地图API坐标系统比较与转换;
 * WGS84坐标系：即地球坐标系，国际上通用的坐标系。设备一般包含GPS芯片或者北斗芯片获取的经纬度为WGS84地理坐标系,
 * 谷歌地图采用的是WGS84地理坐标系（中国范围除外）;
 * GCJ02坐标系：即火星坐标系，是由中国国家测绘局制订的地理信息系统的坐标系统。由WGS84坐标系经加密后的坐标系。
 * 谷歌中国地图和搜搜中国地图采用的是GCJ02地理坐标系; BD09坐标系：即百度坐标系，GCJ02坐标系经加密后的坐标系;
 * 搜狗坐标系、图吧坐标系等，估计也是在GCJ02基础上加密而成的。 chenhua
 */

 let a : Double = 6378245.0;
 let ee : Double = 0.00669342162296594323;

class CoordinateManager: NSObject {
    /**
     * 84 to 火星坐标系 (GCJ-02) World Geodetic System ==> Mars Geodetic System
     *
     * @param lat
     * @param lon
     * @return
     */
    class func gps84_To_Gcj02(lat:Double,lon:Double)->CLLocationCoordinate2D {
        var dLat :Double =  transformLat(x: lon - 105.0, y: lat - 35.0);
        var dLon : Double = transformLon(x: lon - 105.0, y: lat - 35.0);
        let radLat : Double = lat / 180.0 * .pi;
        var magic : Double = sin(radLat);
        magic = 1 - ee * magic * magic;
        let sqrtMagic : Double = sqrt(magic);
        dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * .pi);
        dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * .pi);
        let mgLat : Double = lat + dLat;
        let mgLon : Double = lon + dLon;
        
        var gps = CLLocationCoordinate2D()
        gps.latitude = mgLat;
        gps.longitude = mgLon;
        
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
    
    class func gcj_To_Gps84( lat:Double,  lon:Double)->CLLocationCoordinate2D {
        let gps : CLLocationCoordinate2D? = transform(lat: lat, lon: lon);
        let lontitude : Double = lon * 2 - gps!.longitude;
        let latitude : Double = lat * 2 - gps!.latitude;
    
        var location : CLLocationCoordinate2D? = CLLocationCoordinate2D()
        location?.longitude = lontitude;
        location?.latitude = latitude;
        return location!;
    }
    
    /**
     * 火星坐标系 (GCJ-02) 与百度坐标系 (BD-09) 的转换算法
     将 GCJ-02 坐标转换成 BD-09 坐标
     *
     * @param gg_lat
     * @param gg_lon
     */
    class func gcj02_To_Bd09( gg_lat: Double,  gg_lon:Double) ->CLLocationCoordinate2D{
        let x : Double = gg_lon
        let y : Double = gg_lat
        let z : Double = sqrt(x * x + y * y) + 0.00002 * sin(y * .pi)
        let theta : Double = atan2(y, x) + 0.000003 * cos(x * .pi)
        let bd_lon : Double = z * cos(theta) + 0.0065;
        let bd_lat : Double = z * sin(theta) + 0.006;
    
        var gps : CLLocationCoordinate2D? = CLLocationCoordinate2D()
        gps?.latitude = bd_lat;
        gps?.longitude = bd_lon;
        return gps!;
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
    class func bd09_To_Gcj02( bd_lat:Double,  bd_lon:Double)->CLLocationCoordinate2D {
        let x : Double = bd_lon - 0.0065
        let y : Double = bd_lat - 0.006;
        let z : Double = sqrt(x * x + y * y) - 0.00002 * sin(y * .pi);
        let theta : Double = atan2(y, x) - 0.000003 * cos(x * .pi);
        let gg_lon : Double = z * cos(theta);
        let gg_lat : Double = z * sin(theta);
    
        var gps : CLLocationCoordinate2D? = CLLocationCoordinate2D()
        gps?.latitude=gg_lat;
        gps?.longitude=gg_lon;
        return gps!;
    }
    
    
    /**
     * (BD-09)-->84
     * @param bd_lat
     * @param bd_lon
     * @return
     */
    class func bd09_To_Gps84( bd_lat:Double,  bd_lon:Double)->CLLocationCoordinate2D {
    
        let gcj02 : CLLocationCoordinate2D? = bd09_To_Gcj02(bd_lat: bd_lat, bd_lon: bd_lon);
        let map84 : CLLocationCoordinate2D? = gcj_To_Gps84(lat: (gcj02?.latitude)!,lon: (gcj02?.longitude)!);
        return map84!;
    }
    
    /**
     * 84-->(BD-09)
     * @param 84_lat
     * @param 84_lon
     * @return
     */
    class func gps84_To_Bd09( bd_lat:Double,  bd_lon:Double) ->CLLocationCoordinate2D {
    
        let gcj02 : CLLocationCoordinate2D = gps84_To_Gcj02(lat: bd_lat, lon: bd_lon);
        let bd09 : CLLocationCoordinate2D = gcj02_To_Bd09(gg_lat: gcj02.latitude,gg_lon: gcj02.longitude);
        return bd09;
    }
    
    
    
    
   class func outOfChina( lat:Double,  lon:Double) -> Bool {
        if (lon < 72.004 || lon > 137.8347){
    return true
        }
        if (lat < 0.8293 || lat > 55.8271){
    return true
        }
    return false;
    }
    
    
    
    class func transform( lat:Double,  lon:Double)->CLLocationCoordinate2D {
        if (outOfChina(lat: lat, lon: lon)) {
        var gps = CLLocationCoordinate2D ()
    gps.latitude = lat;
    gps.longitude = lon;
    return gps;
    }
    
        var dLat : Double = transformLat(x: lon - 105.0, y: lat - 35.0);
        var dLon : Double = transformLon(x: lon - 105.0, y: lat - 35.0);
        let radLat : Double = lat / 180.0 * .pi;
        var magic : Double = sin(radLat);
        magic = 1 - ee * magic * magic;
        let sqrtMagic : Double = sqrt(magic);
        dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * .pi);
        dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * .pi);
        let mgLat : Double = lat + dLat;
        let mgLon : Double = lon + dLon;
    
        var gps : CLLocationCoordinate2D? = CLLocationCoordinate2D()
        gps?.latitude = mgLat;
        gps?.longitude = mgLon;
        return gps!;
    }
    
    
   class  func transformLat( x:Double,  y:Double)->Double {
        var  ret:Double = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y
    + 0.2 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * .pi) + 20.0 * sin(2.0 * x * .pi)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * .pi) + 40.0 * sin(y / 3.0 * .pi)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * .pi) + 320 * sin(y * .pi / 30.0)) * 2.0 / 3.0;
    return ret;
    }
    
   class func transformLon( x:Double,  y:Double)->Double {
        var ret : Double = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1
    * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * .pi) + 20.0 * sin(2.0 * x * .pi)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * .pi) + 40.0 * sin(x / 3.0 * .pi)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 * .pi) + 300.0 * sin(x / 30.0 * .pi)) * 2.0 / 3.0;
    return ret;
    }
}














