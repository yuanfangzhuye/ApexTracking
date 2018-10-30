//
//  UITableView+PEX.m
//  ChinapexAnalytics
//
//  Created by chinapex on 2018/3/23.
//  Copyright © 2018年 Gary Chi. All rights reserved.
//

#import "UITableView+PEX.h"

@implementation UITableView (PEX)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
            [PEXMethodSwizzlingUtil methodSwizzle:self.class origin:@selector(setDelegate:) new:@selector(pex_setDelegate:)];
    });
}

#pragma mark - delegate hook
- (void)pex_setDelegate:(id<UITableViewDelegate>)delegate{
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wundeclared-selector"
    
    if ([delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        BOOL isAddSuccess = class_addMethod(delegate.class, @selector(pex_tableViewDidSelectRowAtIndexPath::), (IMP)pex_tableViewDidSelectRowAtIndexPath, "v@:@@");
        if (isAddSuccess) {
            [PEXMethodSwizzlingUtil methodSwizzle:delegate.class origin:@selector(tableView:didSelectRowAtIndexPath:) new:@selector(pex_tableViewDidSelectRowAtIndexPath::)];
        }
    }
#pragma clang diagnostic pop
    [self pex_setDelegate:delegate];
}

- (void)panges:(UIPanGestureRecognizer*)pan{
    
}

void pex_tableViewDidSelectRowAtIndexPath(id self, SEL _cmd, id tableView, id indexpath){
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wundeclared-selector"
    [self performSelector:@selector(pex_tableViewDidSelectRowAtIndexPath::) withObject:tableView withObject:indexpath];
#pragma clang diagnostic pop
    
    
    NSIndexPath *index = (NSIndexPath *)indexpath;
    UITableView *aTableView = (UITableView*)tableView;
    
    if (![[APEXDataCollectSDK shareCollector] isEventTypeIgnored:ApexAnalyticEventType_Click]) {
        UITableViewCell *cell = [aTableView cellForRowAtIndexPath:index];
        [PEXViewPathAnalytor pex_viewPathOfView:cell completeHandler:^(PEXEventBasicModel *model) {
            [[APEXDataCollectSDK shareCollector] track:model TrackType:ApexTrackType_Click];
        }];
    }
}
@end
