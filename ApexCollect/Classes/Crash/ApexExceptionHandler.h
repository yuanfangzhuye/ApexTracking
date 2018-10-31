//
//  ApexExceptionHandler.h
//  ApexTracker
//
//  Created by 李超 on 2018/10/17.
//  Copyright © 2018年 LiChao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ApexExceptionHandler : NSObject

+ (instancetype)sharedHandler;
- (void)setupHandlers;

@end

NS_ASSUME_NONNULL_END
