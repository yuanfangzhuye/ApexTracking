//
//  PEXViewControllerDataTrackerProtocal.h
//  DataCollector
//
//  Created by yulin chi on 2018/10/9.
//  Copyright © 2018 yulin chi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PEXViewControllerDataTrackerProtocal <NSObject>
@optional
- (NSString*)screenTitle; /* 自定义title 默认vc的title */
- (NSString*)screenUrl; /* 当前页面的url */
- (NSDictionary*)trackProperties; /* 自定义携带的数据 */
@end

NS_ASSUME_NONNULL_END
