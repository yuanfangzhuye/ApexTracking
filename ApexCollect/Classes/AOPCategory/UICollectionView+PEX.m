//
//  UICollectionView+PEX.m
//  ChinapexAnalytics
//
//  Created by chinapex on 2018/3/26.
//  Copyright © 2018年 Gary Chi. All rights reserved.
//

#import "UICollectionView+PEX.h"

@implementation UICollectionView (PEX)
+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [PEXMethodSwizzlingUtil methodSwizzle:self.class origin:@selector(setDelegate:) new:@selector(pex_setDelegate:)];
    });
}

- (void)pex_setDelegate:(id<UICollectionViewDelegate>)delegate{
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wundeclared-selector"
    
    if ([delegate respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
        @try {
            BOOL isAddSeccess = class_addMethod(delegate.class, @selector(pex_collectionViewDidSelectItem::), (IMP)pex_collectionViewDidSelectItem, "v@:@@");
            if (isAddSeccess) {
                [PEXMethodSwizzlingUtil methodSwizzle:delegate.class origin:@selector(collectionView:didSelectItemAtIndexPath:) new:@selector(pex_collectionViewDidSelectItem::)];
            }
        } @catch (NSException *exception) {
            [[PEXLogger sharedInstance] error:exception];
        }
    }
    
#pragma clang diagnostic pop
    [self pex_setDelegate:delegate];
}

void pex_collectionViewDidSelectItem(id self, SEL _cmd, id collectionView, id indexPath){
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wundeclared-selector"
    [self performSelector:@selector(pex_collectionViewDidSelectItem::) withObject:collectionView withObject:indexPath];
    
#pragma clang diagnostic pop
    
    if (![[APEXDataCollectSDK shareCollector] isEventTypeIgnored:ApexAnalyticEventType_Click]) {
        UICollectionView *aCollectionView = (UICollectionView*)collectionView;
        NSIndexPath *index = (NSIndexPath*)indexPath;
        UICollectionViewCell *cell = [aCollectionView cellForItemAtIndexPath:index];
        [PEXViewPathAnalytor pex_viewPathOfView:cell completeHandler:^(PEXEventBasicModel *model) {
            [[APEXDataCollectSDK shareCollector] track:model TrackType:ApexTrackType_Click];
        }];
    }
    
}

@end
