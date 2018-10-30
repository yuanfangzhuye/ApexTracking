//
//  PEXLogger.h
//  ChinapexAnalytics
//
//  Created by Cedric Wu on 2017/7/18.
//  Copyright © 2017年 Cedric Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, LoggerLevel) {
    LoggerLevelNone = 0, /* 不打印任何log */
    LoggerLevelError = 9,
    LoggerLevelInfo = 7,
    LoggerLevelDebug = 5,
    LoggerLevelVerbose = 1, /* 最高权限 打印全部log*/
};

#define debugLogger(log) [[PEXLogger sharedInstance] debug:log]
@interface PEXLogger : NSObject

+ (instancetype)sharedInstance;

- (void)setLogLevel:(LoggerLevel)aLevel;

- (void)error:(id)log;
- (void)info:(id)log;
- (void)debug:(id)log;
- (void)Verbose:(id)log;

@end
