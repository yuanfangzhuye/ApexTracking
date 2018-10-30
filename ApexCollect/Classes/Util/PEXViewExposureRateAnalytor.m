//
//  PEXViewExposureRateAnalytor.m
//  ApexCollect
//
//  Created by yulin chi on 2018/10/29.
//  Copyright © 2018 yulin chi. All rights reserved.
//

#import "PEXViewExposureRateAnalytor.h"
@interface PEXViewExposureRateAnalytor()
@property (nonatomic, strong) NSMutableDictionary *exposureRecords; /**< 页面曝光记录 */
@property (nonatomic, strong) UIViewController *exposureController; /**<  */
@property (nonatomic, strong) id<AspectToken> token; /**<  */
@end

@implementation PEXViewExposureRateAnalytor
singleM(exposureRateAnalytor)

//1.可见的View算一次曝光
//2.回退后的视图算一次曝光
//3.cell/item 滑动停止时 可见cell/item算一次曝光
//4.首次进table/collection时的cell/item算一次曝光
- (void)viewExposureRateCaculate:(UIViewController *)viewController{
    //时机:在vc的didAppear调用此方法,
    //判断VC是否UITableVC/UICollectiongVC
    //判断viewController.view以及其subviews是否tableView/CollectiongView
    //若是UIView算一次曝光
    //若是UITableView/UICollectionView 可见区域的cell算一次曝光
    //cell/item 滑动停止时 可见cell/item算一次曝光
    
    @try {
        if ([viewController isKindOfClass:UINavigationController.class]) return;
        
        _exposureController = viewController;
        
        if ([viewController isKindOfClass:UITableViewController.class] || [viewController isKindOfClass:UICollectionViewController.class]) {
            [self scrollableViewExposure:viewController.view];
        }else{
            UIView *view = viewController.view;
            if ([view isKindOfClass:UIScrollView.class]) {
                [self scrollableViewExposure:view];
            }else{
                
                UIView *scrollableView = nil;
                for (UIView *subView in view.subviews) {
                    if ([subView isKindOfClass:UIScrollView.class]) {
                        scrollableView = subView;
                        break;
                    }
                }
                
                if (scrollableView) {
                    [self scrollableViewExposure:scrollableView];
                }else{
                    [self viewExposure:view];
                }
            }
        }
    } @catch (NSException *exception) {
        [[PEXLogger sharedInstance] error:exception];
    }
    
    
}

- (void)viewExposure:(UIView*)view{
    [[PEXLogger sharedInstance] info:[NSString stringWithFormat:@"viewExposure: %@",view]];
}

- (void)scrollableViewExposure:(UIView*)scrollableView{
    
    [[PEXLogger sharedInstance] info:[NSString stringWithFormat:@"scrollableViewExposure: %@",scrollableView]];
    if (![scrollableView isKindOfClass:UIScrollView.class]) return;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
    //注意关闭此aop
    self.token = [scrollableView aspect_hookSelector:@selector(_scrollViewDidEndDeceleratingForDelegate) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspect) {
        NSLog(@"");
    }
                             error:nil];
#pragma clang diagnostic pop
}


- (void)closerViewExposureRateCaculateForVC:(UIViewController *)vc{
    if (vc == self.exposureController) {
        [self.token remove];
    }
}

#pragma mark - getter
- (NSMutableDictionary *)exposureRecords{
    if (!_exposureRecords) {
        _exposureRecords = [NSMutableDictionary dictionary];
    }
    return _exposureRecords;
}
@end
