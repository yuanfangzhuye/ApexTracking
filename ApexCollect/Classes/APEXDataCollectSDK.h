//
//  APEXDataCollectSDK.h
//  DataCollector
//
//  Created by yulin chi on 2018/10/17.
//  Copyright © 2018 yulin chi. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PEXBaseModel;

typedef NS_ENUM(NSUInteger, ApexAnalyticEventType) {
    ApexAnalyticEventType_None = 0,
    ApexAnalyticEventType_AppLaunch = 1 << 0,
    ApexAnalyticEventType_AppDead = 1 << 1,
    ApexAnalyticEventType_Click = 1 << 2,
    ApexAnalyticEventType_ViewController = 1 << 3
};


typedef NS_ENUM(NSUInteger, ApexTrackType) {
    ApexTrackType_ViewPage = 1 << 0,
    ApexTrackType_Click = 1 << 1,
};

@interface APEXDataCollectSDK : NSObject
+ (instancetype)shareCollector;

@property (nonatomic, copy, readonly) NSString *serverUrl;
@property (nonatomic,strong, readonly) NSString *UUID; /**<  */

/**
 初始化方法

 @param serverUrl 服务端域名
 */
- (void)startCollectorWithServersUrl:(NSString*)serverUrl;


/**
 设置追踪事件类型

 @param eventType 事件类型 追踪多个事件可用 | 操作
 */
- (void)configAutoTrackEventType:(ApexAnalyticEventType)eventType;


/**
 此事件类型是否被追踪
 */
- (BOOL)isEventTypeIgnored:(ApexAnalyticEventType)eventType;


/**
 标识用户id
 */
- (void)ConfigUUID:(NSString*)UUID;


/**
 追踪此事件
 */
- (void)track:(PEXBaseModel*)model TrackType:(ApexTrackType)type;

/**
 用户自定义的全局数据, 将会并入autoTrackProperties里
 */
- (void)configDynamicSuperProperties:(NSDictionary* (^)(void))superProperties;
@end
