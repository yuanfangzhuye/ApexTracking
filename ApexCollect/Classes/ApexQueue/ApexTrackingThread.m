//
//  ApexTrackingThread.m
//  ApexTracker
//
//  Created by 李超 on 2018/10/24.
//  Copyright © 2018 LiChao. All rights reserved.
//

#import "ApexTrackingThread.h"

@interface ApexTrackingThread ()

@property (nonatomic, copy) dispatch_block_t successBlock;

@end

@implementation ApexTrackingThread

+ (instancetype)sharedThreadInstance
{
    static ApexTrackingThread *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (void)startRunLoopSuccessBlock:(dispatch_block_t)block
{
    ApexTrackingThread *thread = [[ApexTrackingThread alloc] initWithTarget:self selector:@selector(runLoopRun) object:nil];
    thread.name = @"apex runloop thred";
    self.successBlock = block;
    [thread start];
}

- (void)runLoopRun
{
    [[NSRunLoop currentRunLoop] addPort:[NSPort port] forMode:NSDefaultRunLoopMode];
    self.threadRunLoop = [NSRunLoop currentRunLoop];
    
    if (@available(iOS 10.0, *)) {
        [self.threadRunLoop addTimer:[NSTimer timerWithTimeInterval:600 repeats:YES block:^(NSTimer * _Nonnull timer) {
        }] forMode:NSDefaultRunLoopMode];
    }
    else {
        [self.threadRunLoop addTimer:[NSTimer timerWithTimeInterval:600 target:self selector:@selector(timerRun) userInfo:nil repeats:YES] forMode:NSDefaultRunLoopMode];
    }
    
    if (self.successBlock) {
        self.successBlock();
    }
    
    [[NSRunLoop currentRunLoop] run];
    [[PEXLogger sharedInstance] debug:@"runloop run failed"];
}

- (void)timerRun {
    
}

@end
