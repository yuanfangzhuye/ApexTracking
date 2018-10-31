//
//  ApexTracksQueue.h
//  ApexTracker
//
//  Created by 李超 on 2018/10/23.
//  Copyright © 2018 LiChao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApexTracksQueue : NSObject

/**
 触发上传的占用条件，单位为kb
 */
@property (assign, nonatomic) double kTriggerUploadSize;


/**
 触发上传的时间条件，单位为秒
 */
@property (assign, nonatomic) double kTriggerUploadTime;

+ (instancetype)sharedTracksQueueInstance;

- (void)addApexModelToQueue:(id)model;
- (void)start;
- (void)stop;

/**
 把队列存入数据库，然后清空队列
 */
- (void)saveQueueToDatabaseCompleteHandler:(dispatch_block_t)handler;
- (NSInteger)queueSize;

/**
 从数据库的表中读出队列
 */
- (void)loadQueueFromTable:(NSString *)trackingID;

/**
 从数据库删除表
 */
- (void)clearUserTrackingDatas;

@end
