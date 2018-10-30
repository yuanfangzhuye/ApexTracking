//
//  PEXQueue.h
//  DataCollector
//
//  Created by yulin chi on 2018/10/9.
//  Copyright © 2018 yulin chi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PEXEventBasicModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PEXQueue : NSObject
singleH(Queue)

- (void)addToQueue:(PEXEventBasicModel*)model;

@end

NS_ASSUME_NONNULL_END
