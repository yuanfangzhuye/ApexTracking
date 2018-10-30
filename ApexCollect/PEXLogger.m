//
//  PEXLogger.m
//  ChinapexAnalytics
//
//  Created by Cedric Wu on 2017/7/18.
//  Copyright © 2017年 Cedric Wu. All rights reserved.
//

#import "PEXLogger.h"

@interface PEXLogger ()

@property (nonatomic) LoggerLevel loggerLevel;

@end

@implementation PEXLogger

static PEXLogger *_instance = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

#pragma mark - Public Methods
- (void)setLogLevel:(LoggerLevel)aLevel {
    self.loggerLevel = aLevel;
}

- (void)error:(id)log {
    if ([self shouldLog:LoggerLevelError]) {
        [self log:log];
    }
}

- (void)info:(id)log {
    if ([self shouldLog:LoggerLevelInfo]) {
        [self log:log];
    }
}

- (void)debug:(id)log {
    if ([self shouldLog:LoggerLevelDebug]) {
        [self log:log];
    }
}

- (void)Verbose:(id)log {
    if ([self shouldLog:LoggerLevelVerbose]) {
        [self log:log];
    }
}

#pragma mark - Private Methods
- (BOOL)shouldLog:(LoggerLevel)aLevel {
    if (self.loggerLevel == LoggerLevelNone) {
        return NO;
    }
    if (self.loggerLevel <= aLevel) {
        return YES;
    }
    return NO;
}

- (void)log:(id)logString {
    NSLog(@"chinapex: %@", logString);
}

#pragma mark - setter getter
- (LoggerLevel)loggerLevel {
    if (!_loggerLevel) {
        _loggerLevel = LoggerLevelNone;
    }
    return _loggerLevel;
}

@end
