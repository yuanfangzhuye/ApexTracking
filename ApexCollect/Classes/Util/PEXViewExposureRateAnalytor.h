//
//  PEXViewExposureRateAnalytor.h
//  ApexCollect
//
//  Created by yulin chi on 2018/10/29.
//  Copyright © 2018 yulin chi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PEXViewExposureRateAnalytor : NSObject
singleH(exposureRateAnalytor);
- (void)viewExposureRateCaculate:(UIViewController *)viewC;
- (void)closerViewExposureRateCaculateForVC:(UIViewController*)vc;
@end

NS_ASSUME_NONNULL_END
