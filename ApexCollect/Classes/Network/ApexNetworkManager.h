//
//  ApexNetworkManager.h
//  ApexTracker
//
//  Created by 李超 on 2018/10/19.
//  Copyright © 2018年 LiChao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ApexBaseNetwork.h"

@class ApexModel;

NS_ASSUME_NONNULL_BEGIN

@interface ApexNetworkManager : NSObject

+ (instancetype)sharedInstance;

//单个上传
- (void)uploadDataToServer:(id)datas responseSuccess:(callBackSuccess)success responseFailed:(callBackFailed)failed;

@end

NS_ASSUME_NONNULL_END
