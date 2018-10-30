//
//  UIControl+PEX.m
//  ChinapexAnalytics
//
//  Created by chinapex on 2018/3/23.
//  Copyright © 2018年 Gary Chi. All rights reserved.
//

#import "UIControl+PEX.h"

const char* kControlEvent = "kControlEvent";
const char* kControlAction = "kControlAction";

@interface UIControl()
@property (nonatomic, strong) NSNumber *pex_controlEvent;
@end

@implementation UIControl (PEX)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [PEXMethodSwizzlingUtil methodSwizzle:self origin:@selector(addTarget:action:forControlEvents:) new:@selector(pex_addTarget:action:forControlEvents:)];
        
        [PEXMethodSwizzlingUtil methodSwizzle:self origin:@selector(sendAction:to:forEvent:) new:@selector(pex_sendAction:to:forEvent:)];
    });
}

- (void)pex_addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents{
    self.pex_controlEvent = @(controlEvents);
    self.pex_ActionString = NSStringFromSelector(action);
    [self pex_addTarget:target action:action forControlEvents:controlEvents];
}

- (void)pex_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event{
   
    if (![[APEXDataCollectSDK shareCollector] isEventTypeIgnored:ApexAnalyticEventType_Click]) {
        [[PEXLogger sharedInstance] debug:[NSString stringWithFormat:@"sender class %@", [self class]]];
        
        [PEXViewPathAnalytor pex_viewPathOfView:self completeHandler:^(PEXEventBasicModel *model) {
            [[APEXDataCollectSDK shareCollector] track:model TrackType:ApexTrackType_Click];
        }];
    }
    
    [self pex_sendAction:action to:target forEvent:event];
}

#pragma mark - setter getter
- (void)setPex_controlEvent:(NSNumber *)pex_controlEvent{
    objc_setAssociatedObject(self, kControlEvent, pex_controlEvent, OBJC_ASSOCIATION_RETAIN);
}

- (NSNumber *)pex_controlEvent{
    return objc_getAssociatedObject(self, kControlEvent);
}

- (void)setPex_ActionString:(NSString *)pex_ActionString{
    objc_setAssociatedObject(self, kControlAction, pex_ActionString, OBJC_ASSOCIATION_RETAIN);
}

- (NSString *)pex_ActionString{
    return objc_getAssociatedObject(self, kControlAction);
}

@end
