//
//  APEXDataCollectSDK.m
//  DataCollector
//
//  Created by yulin chi on 2018/10/17.
//  Copyright © 2018 yulin chi. All rights reserved.
//

#import "APEXDataCollectSDK.h"
#import "PEXKeyChain.h"

static NSString* const AppNameKey = @"$AppNameKey";
static NSString* const AppVersionKey = @"$AppVersionKey";
static NSString* const AppBuildKey = @"$AppBuildKey";

static NSString* const DeviceVersionKey = @"$DeviceVersionKey";
static NSString* const DeviceNameKey = @"$DeviceNameKey";
static NSString* const DeviceFrameKey = @"$DeviceFrameKey";

@interface APEXDataCollectSDK()
@property (nonatomic, assign) ApexAnalyticEventType autoTrackEventType;
@property (nonatomic, strong) NSMutableDictionary *autoTrackProperties; /**< default track info */
@end

@implementation APEXDataCollectSDK
singleM(Collector);

- (void)startCollectorWithServersUrl:(NSString *)serverUrl{
    NSAssert(serverUrl != nil, @"serverUrl Cannot be nil !");
    _serverUrl = serverUrl;
    
    //启动网络监控
    
    //启动事件队列
    
    //启动崩溃监控
    
    //设置sdk默认值
    [self setDefaultValue];
}


- (void)setDefaultValue{
    _autoTrackEventType = ApexAnalyticEventType_None;
    _autoTrackProperties = [self setAutoTrackProperties];
}

#pragma mark - config
- (void)configAutoTrackEventType:(ApexAnalyticEventType)eventType{
    _autoTrackEventType = eventType;
}

- (void)ConfigUUID:(NSString *)UUID{
    
    if (UUID && UUID.length != 0) {
        _UUID = UUID;
    }
}

- (void)configDynamicSuperProperties:(NSDictionary* (^)(void))superProperties{
    NSDictionary *userSuperProperties = superProperties();
    [self.autoTrackProperties addEntriesFromDictionary:userSuperProperties];
    
    [[PEXLogger sharedInstance] info:[NSString stringWithFormat:@"autoTrackProperties: %@",self.autoTrackProperties]];
}

- (NSMutableDictionary*)setAutoTrackProperties{
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    
    // app名称
    NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    // app版本
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    // app build版本
    NSString *app_build = [infoDictionary objectForKey:@"CFBundleVersion"];
    
    [properties setValue:app_Name forKey:AppNameKey];
    [properties setValue:app_Version forKey:AppVersionKey];
    [properties setValue:app_build forKey:AppBuildKey];
    
    //device
    [properties setValue:[UIDevice currentDevice].systemVersion forKey:DeviceVersionKey];
    [properties setValue:[UIDevice currentDevice].systemName forKey:DeviceNameKey];
    CGRect bounds = [UIScreen mainScreen].bounds;
    [properties setValue:[NSString stringWithFormat:@"[x:%f,y:%f,width:%f,height:%f]",bounds.origin.x,bounds.origin.y,bounds.size.width,bounds.size.height] forKey:DeviceFrameKey];
    
    return properties;
}

#pragma mark - track
- (void)track:(PEXBaseModel*)model TrackType:(ApexTrackType)type{
    //数据统一出口, 外部只需要数据字典,无需感知数据模型
    [[PEXLogger sharedInstance] info:[model toDict]];
}

#pragma mark - Util
- (BOOL)isEventTypeIgnored:(ApexAnalyticEventType)eventType{
    //判断是否有远程disable
    
    //判断初始化设置的types
    return !(_autoTrackEventType & eventType);
}
@end
