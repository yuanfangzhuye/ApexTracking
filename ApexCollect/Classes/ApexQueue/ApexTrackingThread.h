//
//  ApexTrackingThread.h
//  ApexTracker
//
//  Created by 李超 on 2018/10/24.
//  Copyright © 2018 LiChao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ApexTrackingThread : NSThread

@property (nonatomic, strong) NSRunLoop *threadRunLoop;

+ (instancetype)sharedThreadInstance;
- (void)startRunLoopSuccessBlock:(dispatch_block_t)block;

@end

NS_ASSUME_NONNULL_END
