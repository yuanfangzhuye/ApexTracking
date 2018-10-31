//
//  ApexSqliteManager.h
//  ApexTracker
//
//  Created by 李超 on 2018/10/22.
//  Copyright © 2018 LiChao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApexSqliteManager : NSObject

+ (instancetype)sharedSqliteManager;

- (NSError *)createUserTableWithTrackingID:(NSString *)trackingID;

- (NSArray *)query:(NSString *)sql error:(NSError **)error;
- (int64_t)update:(NSString *)sql with:(NSArray *)params error:(NSError *__autoreleasing *)error;

@end
