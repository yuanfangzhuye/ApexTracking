//
//  UINavigationController+PEX.m
//  ApexCollect
//
//  Created by yulin chi on 2018/10/25.
//  Copyright © 2018 yulin chi. All rights reserved.
//

#import "UINavigationController+PEX.h"
#import "PEXViewPageVisibilityAnalytor.h"

@implementation UINavigationController (PEX)

//+ (void)load{
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//
//        @try {
//            [self aspect_hookSelector:@selector(pushViewController:animated:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspect, UIViewController *toVC, BOOL animated){
//
//                UINavigationController *navVC = aspect.instance;
//                [navVC pex_pushViewController:toVC animation:animated];
//
//            } error:nil];
//
//
//            [self aspect_hookSelector:@selector(popViewControllerAnimated:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspect, BOOL animated){
//
//                UINavigationController *navVC = aspect.instance;
//                [navVC pex_popViewControllerAnimated:animated];
//
//            } error:nil];
//
//        } @catch (NSException *exception) {
//            [[PEXLogger sharedInstance] error:exception];
//        }
//
//    });
//}

//vc曝光
- (void)pex_pushViewController:(UIViewController*)vc animation:(BOOL)animate{
    [PEXViewPageVisibilityAnalytor viewControllerVisibilityStreamAnalytior:self.visibleViewController];
}

- (void)pex_popViewControllerAnimated:(BOOL)animated{
    [PEXViewPageVisibilityAnalytor viewControllerVisibilityStreamAnalytior:self.visibleViewController];
}

@end
