//
//  UIView+Gesture.m
//  DataCollector
//
//  Created by yulin chi on 2018/9/28.
//  Copyright © 2018年 yulin chi. All rights reserved.
//

#import "UIView+Gesture.h"

const char *apexAutoTrackePropertiesKey = "apexAutoTrackePropertiesKey";

@implementation UIView (Gesture)
+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [PEXMethodSwizzlingUtil methodSwizzle:self origin:@selector(addGestureRecognizer:) new:@selector(pex_AddGestureRecognizer:)];
    });
}


- (void)pex_AddGestureRecognizer:(UIGestureRecognizer*)ges{
    if ([ges isKindOfClass:[UITapGestureRecognizer class]] || [ges isKindOfClass:[UILongPressGestureRecognizer class]]) {
        [ges addTarget:self action:@selector(gestureMonitorAction)];
    }
    [self pex_AddGestureRecognizer:ges];
}

- (void)gestureMonitorAction{
    
    if (![[APEXDataCollectSDK shareCollector] isEventTypeIgnored:ApexAnalyticEventType_Click]) {
        [PEXViewPathAnalytor pex_viewPathOfView:self completeHandler:^(PEXEventBasicModel *model) {
           [[APEXDataCollectSDK shareCollector] track:model TrackType:ApexTrackType_Click];
        }];
    }
}

#pragma mark - getter setter
- (NSDictionary *)apexAutoTrackProperties{
    return objc_getAssociatedObject(self, apexAutoTrackePropertiesKey);
}

- (void)setApexAutoTrackProperties:(NSDictionary *)apexAutoTrackProperties{
    objc_setAssociatedObject(self, apexAutoTrackePropertiesKey, apexAutoTrackProperties, OBJC_ASSOCIATION_RETAIN);
}

@end
