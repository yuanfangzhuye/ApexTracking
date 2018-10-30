//
//  PEXViewPathAnalytor.h
//  ChinapexAnalytics
//
//  Created by chinapex on 2018/3/23.
//  Copyright © 2018年 Gary Chi. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PEXEventBasicModel;

typedef void(^completeHandler)(PEXEventBasicModel *model);

@interface PEXViewPathAnalytor : NSObject
+ (void)pex_viewPathOfView:(id)view completeHandler:(completeHandler)handler;
@end
