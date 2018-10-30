//
//  UIViewController+PEX.h
//  ChinapexAnalytics
//
//  Created by Cedric Wu on 2017/7/19.
//  Copyright © 2017年 Cedric Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (PEX)
@property (nonatomic, strong) NSNumber *pex_stayInterval; /* 在此vc的停留时间 */
@property (nonatomic, strong) NSNumber *pex_entryInterval;
@property (nonatomic, strong) NSNumber *pex_leaveInterval;
@end
