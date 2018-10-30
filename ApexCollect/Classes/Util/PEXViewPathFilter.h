//
//  PEXViewPathFilter.h
//  DataCollector
//
//  Created by yulin chi on 2018/9/27.
//  Copyright © 2018年 yulin chi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PEXViewPathFilter : NSObject

//此view的类是否在黑名单中
+ (BOOL)isViewInBlackListByClass:(NSString*)className;
@end

NS_ASSUME_NONNULL_END
