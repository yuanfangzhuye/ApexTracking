//
//  ApexTracksQueue.m
//  ApexTracker
//
//  Created by 李超 on 2018/10/23.
//  Copyright © 2018 LiChao. All rights reserved.
//

#import "ApexTracksQueue.h"
#import "ApexNetworkManager.h"
#import "PEXEventBasicModel.h"

const NSInteger maxCount = 3000;

static int eventsNumLimits = 50;

@interface ApexTracksQueue ()

@property (strong, nonatomic) NSMutableArray<PEXEventBasicModel *> *queue;
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) NSInteger netWorkFailedCount;

@end

@implementation ApexTracksQueue

- (instancetype)init {
    self = [super init];
    if (self) {
        _kTriggerUploadSize = 60;
        _kTriggerUploadTime = 6.0f;
        _queue = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (instancetype)sharedTracksQueueInstance
{
    static ApexTracksQueue *tracksQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tracksQueue = [[self alloc] init];
    });
    
    return tracksQueue;
}

- (void)addApexModelToQueue:(id)model
{
    if (self.queue.count >= maxCount) return;
    [self.queue addObject:model];
}

- (void)start {
    if (self.timer == nil) {
        self.timer = [NSTimer timerWithTimeInterval:self.kTriggerUploadTime target:self selector:@selector(triggerUploadTimeAction) userInfo:nil repeats:YES];
        
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}

- (void)triggerUploadTimeAction {
    // 先取出一份，防止再处理过程中内容改变
    NSArray *uploadArray = [self.queue copy];
    if (uploadArray.count == 0) return;
    
    //网络判断 只有4G和wifi才能上传
    ApexNetWorkStatus connectStatus = [[APEXDataCollectSDK shareCollector] currentNetStatus];
    [[PEXLogger sharedInstance] debug:[NSString stringWithFormat:@"当前网络：%ld", (long)connectStatus]];
    if (connectStatus == ApexNetWorkStatus_4G || connectStatus == ApexNetWorkStatus_WIFI) {
        if (uploadArray.count < eventsNumLimits) {
            [self treatEventsWithInNumLimits:uploadArray];
        }
        else {
            NSArray *splitArr = [PEXCommonUtil splitArray:uploadArray withSubSize:eventsNumLimits];
            for (NSArray *subArr in splitArr) {
                [self treatEventsOutsNumLimits:subArr];
            }
        }
    }
}

- (void)treatEventsWithInNumLimits:(NSArray*)uploadArray {
    [uploadArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [[ApexNetworkManager sharedInstance] uploadDataToServer:obj responseSuccess:^(NSURLResponse *response) {
            [[PEXLogger sharedInstance] debug:@"send 发送请求success"];
            // 删除已经处理过的
            [self.queue removeObject:obj];
        } responseFailed:^(NSError *connErr, NSURLResponse *response) {
            [[PEXLogger sharedInstance] debug:@"send 发送请求fail"];
        }];
        
    }];
}

- (void)treatEventsOutsNumLimits:(NSArray*)uploadArray {
    if (uploadArray.count == 0) return;
    
    [[ApexNetworkManager sharedInstance] uploadDataToServer:uploadArray responseSuccess:^(NSURLResponse *response) {
        [[PEXLogger sharedInstance] debug:@"send 发送请求success"];
        // 删除已经处理过的
        [self.queue removeObjectsInArray:uploadArray];
    } responseFailed:^(NSError *connErr, NSURLResponse *response) {
        [[PEXLogger sharedInstance] debug:@"send 发送请求fail"];
    }];
}

- (void)stop {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)saveQueueToDatabaseCompleteHandler:(dispatch_block_t)handler
{
    [[PEXLogger sharedInstance] debug:@"把剩余队列存入数据库"];
    
    [[PEXLogger sharedInstance] debug:[NSString stringWithFormat:@"存入发送请求 %lu个 @queue:%p",(unsigned long)self.queue.count,self.queue]];
    [self.queue enumerateObjectsUsingBlock:^(PEXEventBasicModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *contentString = [obj toJSON];
        
        NSString *trackingID = [[APEXDataCollectSDK shareCollector] UUID];
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO `%@` VALUES (NULL, ?, ?);", trackingID];
        
        [[ApexSqliteManager sharedSqliteManager] update:sql with:@[[obj eventType], contentString] error:nil];
    }];
    
    if (handler) {
        handler();
    }
    
    [self.queue removeAllObjects];
}

- (NSInteger)queueSize
{
    return self.queue.count;
}

- (void)loadQueueFromTable:(NSString *)trackingID
{
    [[PEXLogger sharedInstance] debug:@"从数据库读出队列"];
    
    NSString *sql = [NSString stringWithFormat:@"select * from `%@`", trackingID];
    
    NSArray *array = [[ApexSqliteManager sharedSqliteManager] query:sql error:nil];
    
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            if ([[obj allKeys] containsObject:@"content"]) {
                NSString *contentString = [((NSDictionary *)obj) valueForKey:@"content"];
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[contentString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
                
                PEXEventBasicModel *model = [[PEXEventBasicModel alloc] initWith:dict];
//                NSString *type = [dict valueForKey:@"type"];
//                if ([type isEqualToString:@"alias"]) {
//                    model = [[PEXRequestDataAliasModel alloc] initWith:dict];
//                } else if ([type isEqualToString:@"event"]) {
//                    model = [[PEXRequestDataEventModel alloc] initWith:dict];
//                } else if ([type isEqualToString:@"identify"]) {
//                    model = [[PEXRequestDataIdentifyModel alloc] initWith:dict];
//                } else {
//                    model = [[ApexModel alloc] initWith:dict];
//                }
                [self addApexModelToQueue:model];
            }
        }
    }];
    [[PEXLogger sharedInstance] debug:[NSString stringWithFormat:@"还有待发送请求 %lu个 @queue:%p",(unsigned long)self.queue.count,self.queue]];
    
    [self clearUserTrackingDatas];
}

- (void)clearUserTrackingDatas
{
    NSString *trackingID = [[APEXDataCollectSDK shareCollector] UUID];
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM `%@`", trackingID];
    [[ApexSqliteManager sharedSqliteManager] query:sql error:nil];
}

@end
