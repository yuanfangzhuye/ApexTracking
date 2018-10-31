//
//  ApexBaseNetwork.h
//  ApexTracker
//
//  Created by 李超 on 2018/10/17.
//  Copyright © 2018年 LiChao. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^callBackSuccess)(NSURLResponse *response);
typedef void(^callBackFailed)(NSError *connErr, NSURLResponse *response);

@interface ApexBaseNetwork : NSObject

+ (instancetype)sharedInstanceNetwork;

//GET
- (NSURLRequest *)getRequestURL:(NSString *)url params:(id)params responseSuccess:(callBackSuccess)success fail:(callBackFailed)failed;

//POST
- (NSURLRequest *)postRequestURL:(NSString *)url params:(id)params responseSuccess:(callBackSuccess)success fail:(callBackFailed)failed;

@end

