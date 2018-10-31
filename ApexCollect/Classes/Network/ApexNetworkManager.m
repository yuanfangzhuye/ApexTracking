//
//  ApexNetworkManager.m
//  ApexTracker
//
//  Created by 李超 on 2018/10/19.
//  Copyright © 2018年 LiChao. All rights reserved.
//

#import "ApexNetworkManager.h"
#import "PEXEventBasicModel.h"
#import "PEXViewPageModel.h"

@implementation ApexNetworkManager

static ApexNetworkManager *_instance = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (void)uploadDataToServer:(id)datas responseSuccess:(callBackSuccess)success responseFailed:(callBackFailed)failed
{
    if ([datas isKindOfClass:[NSArray class]]) {
        for (id obj in datas) {
            [self sendModelToServer:obj callBackSuccess:success callBackFail:failed];
        }
    }
    else {
        [self sendModelToServer:datas callBackSuccess:success callBackFail:failed];
    }
}

- (void)sendModelToServer:(id)model callBackSuccess:(callBackSuccess)success callBackFail:(callBackFailed)failed
{
    if ([model isKindOfClass:[PEXEventBasicModel class]]) {
        PEXEventBasicModel *apex = (PEXEventBasicModel *)model;
        [self postRequest:apex callBackSuccess:success callBackFail:failed];
//        switch (apex.method) {
//            case APexRequestMethodGet:
//            {
//                [self getRequest:apex callBackSuccess:success callBackFail:failed];
//            }
//                break;
//            case APexRequestMethodPost:
//            {
//                [self postRequest:apex callBackSuccess:success callBackFail:failed];
//            }
//                break;
//            default:
//                break;
//        }
    }
}

#pragma mark - Private Methods

- (void)getRequest:(PEXEventBasicModel *)model callBackSuccess:(callBackSuccess)success callBackFail:(callBackFailed)failed{
    [[ApexBaseNetwork sharedInstanceNetwork] getRequestURL:ApexBaseURL params:[model toDictionary] responseSuccess:success fail:failed];
}

- (void)postRequest:(PEXEventBasicModel *)model callBackSuccess:(callBackSuccess)success callBackFail:(callBackFailed)failed{
    [[ApexBaseNetwork sharedInstanceNetwork] postRequestURL:ApexBaseURL params:[model toDictionary] responseSuccess:success fail:failed];
}

@end
