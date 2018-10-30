//
//  UIViewController+PEX.m
//  ChinapexAnalytics
//
//  Created by Cedric Wu on 2017/7/19.
//  Copyright © 2017年 Cedric Wu. All rights reserved.
//

#import "UIViewController+PEX.h"
#import "PEXMethodSwizzlingUtil.h"
#import "PEXLogger.h"
#import "PEXViewControllerDataTrackerProtocal.h"
#import "PEXViewPageModel.h"
#import "PEXViewPageVisibilityAnalytor.h"
#import "PEXViewExposureRateAnalytor.h"

const char *entryKey = "pex_entryKey";
const char *leaveKey = "pex_leaveKey";
const char *stayKey = "pex_stayKey";
const char *pvModelKey = "pex_pvModelKey";

static NSString* const VCClassNameKey = @"$VCClassName";
static NSString* const VCStayDurationKey = @"$VCStayDuration";
static NSString* const VCExtraData = @"$VCExtraData";
static NSString* const VCScreenTitle = @"$VCScreenTitle";
static NSString* const VCScreenUrl = @"$VCScreenUrl";
static NSString* const VCScreenProperties = @"$VCScreenProperties";

@interface UIViewController ()
@property (nonatomic, strong) PEXViewPageModel *pvModel; /**< vc 属性 */
@end

@implementation UIViewController (PEX)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [self aspect_hookSelector:@selector(viewDidAppear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspect, BOOL animated){
            UIViewController *vc = aspect.instance;
            [vc pex_viewDidAppear:animated];
        } error:nil];
        
        [self aspect_hookSelector:@selector(viewDidDisappear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspect, BOOL animated){
            UIViewController *vc = aspect.instance;
            [vc pex_viewDidDisappear:animated];
        } error:nil];
        
//        [self aspect_hookSelector:@selector(presentViewController:animated:completion:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspect, UIViewController *pvc, BOOL animated){
//            UIViewController *vc = aspect.instance;
//            [vc pex_presentViewController:vc animated:animated];
//        } error:nil];
//
//        [self aspect_hookSelector:@selector(dismissViewControllerAnimated:completion:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspect, BOOL animated){
//            UIViewController *vc = aspect.instance;
//            [vc pex_dismissViewControllerAnimated:animated];
//        } error:nil];
        
    });
}

- (void)pex_viewDidAppear:(BOOL)animated {

    if (![[APEXDataCollectSDK shareCollector] isEventTypeIgnored:ApexAnalyticEventType_ViewController]) {
        
        if ([self.parentViewController isKindOfClass:[UITabBarController class]] ||
            [self.parentViewController isKindOfClass:[UINavigationController class]] ) {
            
            [[PEXViewExposureRateAnalytor shareexposureRateAnalytor] viewExposureRateCaculate:self];
            
            self.pvModel = [[PEXViewPageModel alloc] init];
            self.pex_entryInterval = @([NSDate date].timeIntervalSince1970);
            
        }
    }
    
}

- (void)pex_viewDidDisappear:(BOOL)animated {

    if (![[APEXDataCollectSDK shareCollector] isEventTypeIgnored:ApexAnalyticEventType_ViewController]) {
        
        if ([self.parentViewController isKindOfClass:[UITabBarController class]] ||
            [self.parentViewController isKindOfClass:[UINavigationController class]] ) {
            
            if ([self isKindOfClass:UINavigationController.class]) return;
            
            [self caculateStayInterval];
            
            self.pvModel.VCStayDuration = [NSString stringWithFormat:@"%.2f",self.pex_stayInterval.stringValue.doubleValue];
            self.pvModel.VCClassName = NSStringFromClass(self.class);
            
            @try {
                //获取用户自定数据
                if ([self conformsToProtocol:@protocol(PEXViewControllerDataTrackerProtocal)]) {
                    
                    if ([self respondsToSelector:@selector(screenTitle)]) {
                        self.pvModel.VCScreenTitle = [self performSelector:@selector(screenTitle)];
                    }
                    
                    if ([self respondsToSelector:@selector(screenUrl)]) {
                        self.pvModel.VCScreenUrl = [self performSelector:@selector(screenUrl)];
                    }
                    
                    if ([self respondsToSelector:@selector(trackProperties)]) {
                        self.pvModel.VCScreenProperties = [self performSelector:@selector(trackProperties)];
                    }
                }
                
                //vc reference
                NSArray *childVCs = self.navigationController.childViewControllers;
                NSInteger index = [childVCs indexOfObject:self];
                if (index > 0) {
                    UIViewController *reference = childVCs[index - 1];
                    self.pvModel.reference = NSStringFromClass(reference.class);
                }
                
            } @catch (NSException *exception) {
                [[PEXLogger sharedInstance] error:exception];
            }
            
            self.pvModel.timeStamp = @([[NSDate date] timeIntervalSince1970]).stringValue;
            
            [[APEXDataCollectSDK shareCollector] track:self.pvModel TrackType:ApexTrackType_ViewPage];
            
            [[PEXViewExposureRateAnalytor shareexposureRateAnalytor] closerViewExposureRateCaculateForVC:self];
        }
    }
}

- (void)caculateStayInterval{
    self.pex_leaveInterval = @([NSDate date].timeIntervalSince1970);
    self.pex_stayInterval = @(self.pex_leaveInterval.doubleValue - self.pex_entryInterval.doubleValue);
}

//presented VC
- (void)pex_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag{
    [PEXViewPageVisibilityAnalytor viewControllerVisibilityStreamAnalytior:viewControllerToPresent];
}

- (void)pex_dismissViewControllerAnimated:(BOOL)flag{
    [PEXViewPageVisibilityAnalytor viewControllerVisibilityStreamAnalytior:self];
}

#pragma mark - setter
- (PEXViewPageModel *)pvModel{
    return objc_getAssociatedObject(self, pvModelKey);
}

- (void)setPvModel:(PEXViewPageModel *)pvModel{
    objc_setAssociatedObject(self, pvModelKey, pvModel, OBJC_ASSOCIATION_RETAIN);
}

- (void)setPex_entryInterval:(NSNumber *)pex_entryInterval{
    objc_setAssociatedObject(self, entryKey, pex_entryInterval, OBJC_ASSOCIATION_RETAIN);
}

- (NSNumber*)pex_entryInterval{
    return objc_getAssociatedObject(self, entryKey);
}

- (void)setPex_leaveInterval:(NSNumber *)pex_leaveInterval{
    objc_setAssociatedObject(self, leaveKey, pex_leaveInterval, OBJC_ASSOCIATION_RETAIN);
}

- (NSNumber *)pex_leaveInterval{
    return objc_getAssociatedObject(self, leaveKey);
}

- (void)setPex_stayInterval:(NSNumber *)pex_stayInterval{
    objc_setAssociatedObject(self, stayKey, pex_stayInterval, OBJC_ASSOCIATION_RETAIN);
}

- (NSNumber *)pex_stayInterval{
    return objc_getAssociatedObject(self, stayKey);
}
@end
