//
//  UIApplication+PEX.m
//  ChinapexAnalytics
//
//  Created by chinapex on 2018/3/23.
//  Copyright © 2018年 Gary Chi. All rights reserved.
//

#import "UIApplication+PEX.h"

@interface UIApplication()
@end

@implementation UIApplication (PEX)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        //hook方法管理事件队列的本地化与读取时机
        [PEXMethodSwizzlingUtil methodSwizzle:self.class origin:@selector(setDelegate:) new:@selector(pex_setDelegate:)];
    });
}

- (void)pex_setDelegate:(id<UIApplicationDelegate>)delegate{
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    
//    //AppDelegate
    if (delegate) {
        //hook 进入后台的时间 在终止应用时也会调用进入后台的方法
        BOOL isAddSuccess = class_addMethod(delegate.class, @selector(pex_applicationWillResignActivity:), (IMP)pex_applicationWillResignActivity, "v@:@");
        if (isAddSuccess) {
            [PEXMethodSwizzlingUtil methodSwizzle:delegate.class origin:@selector(applicationWillResignActive:) new:@selector(pex_applicationWillResignActivity:)];
        }

        //hook 应用进入前台时的方法
        BOOL isAddSuccess2 = class_addMethod(delegate.class, @selector(pex_applicationDidBecomeActive:), (IMP)pex_applicationDidBecomeActive, "v@:@");
        if (isAddSuccess2) {
            [PEXMethodSwizzlingUtil methodSwizzle:delegate.class origin:@selector(applicationDidBecomeActive:) new:@selector(pex_applicationDidBecomeActive:)];
        }

    }
    
#pragma clang diagnostic pop
  
    [self pex_setDelegate:delegate];
}


/**
 when the application is about to move from active to inactive state
 */
void pex_applicationWillResignActivity(id self, SEL _cmd, id application){
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wundeclared-selector"

    if (![[APEXDataCollectSDK shareCollector] isEventTypeIgnored:ApexAnalyticEventType_AppLaunch]) {
        [[PEXLogger sharedInstance] debug:@"application_ResignActivity"];
        [self performSelector:@selector(pex_applicationWillResignActivity:) withObject:application];
    }
    
#pragma clang diagnostic pop
}


/**
 when the application is about to move from inactive to active state
 */
void pex_applicationDidBecomeActive(id self, SEL _cmd, id application){
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wundeclared-selector"
    
    if (![[APEXDataCollectSDK shareCollector] isEventTypeIgnored:ApexAnalyticEventType_AppDead]) {
        [[PEXLogger sharedInstance] debug:@"application_Active"];
        [self performSelector:@selector(pex_applicationDidBecomeActive:) withObject:application];
    }
#pragma clang diagnostic pop
}

#pragma mark - getter setter

@end
