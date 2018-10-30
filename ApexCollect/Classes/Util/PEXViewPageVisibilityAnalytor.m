//
//  PEXViewPageVisibilityAnalytor.m
//  ApexCollect
//
//  Created by yulin chi on 2018/10/26.
//  Copyright © 2018 yulin chi. All rights reserved.
//

#import "PEXViewPageVisibilityAnalytor.h"

@implementation PEXViewPageVisibilityAnalytor
+ (void)viewControllerVisibilityStreamAnalytior:(UIViewController *)vc{
    if (vc && [vc isKindOfClass:UIViewController.class]) {
        @try {
            [[PEXLogger sharedInstance] info:[NSString stringWithFormat:@"nav pop to: %@",NSStringFromClass(vc.class)]];
            
        } @catch (NSException *exception) {
            [[PEXLogger sharedInstance] error:exception];
        }
    }
}
@end
