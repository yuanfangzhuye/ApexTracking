//
//  PEXViewPageModel.h
//  ApexCollect
//
//  Created by yulin chi on 2018/10/23.
//  Copyright © 2018 yulin chi. All rights reserved.
//

#import "PEXBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PEXViewPageModel : PEXBaseModel
/*
 static NSString* const VCClassNameKey = @"$VCClassName";
 static NSString* const VCStayDurationKey = @"$VCStayDuration";
 static NSString* const VCExtraData = @"$VCExtraData";
 static NSString* const VCScreenTitle = @"$VCScreenTitle";
 static NSString* const VCScreenUrl = @"$VCScreenUrl";
 static NSString* const VCScreenProperties = @"$VCScreenProperties";
 */

@property (nonatomic, copy) NSString *VCClassName; /**<  */
@property (nonatomic, copy) NSString *VCStayDuration; /**<  */
//@property (nonatomic, copy) NSString *VCExtraData; /**<  */
@property (nonatomic, copy) NSString *VCScreenTitle; /**<  */
@property (nonatomic, copy) NSString *VCScreenUrl; /**<  */
@property (nonatomic, copy) NSDictionary *VCScreenProperties; /**<  */
@property (nonatomic, copy) NSString *reference; /**< 来源VC */
@property (nonatomic, copy) NSString *timeStamp; /**<  */
@end

NS_ASSUME_NONNULL_END
