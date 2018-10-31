//
//  PEXEventBasicModel.m
//  DataCollector
//
//  Created by yulin chi on 2018/9/28.
//  Copyright © 2018年 yulin chi. All rights reserved.
//

#import "PEXEventBasicModel.h"

@implementation PEXEventBasicModel

- (instancetype)initWith:(NSDictionary *)dict
{
    self = [self init];
    if (self) {
        [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([key isEqualToString:@"eventType"]) {
                self.eventType = obj;
            }
            if ([key isEqualToString:@"ViewPath"]) {
                self.ViewPath = obj;
            }
            if ([key isEqualToString:@"eventID"]) {
                self.eventID = obj;
            }
            if ([key isEqualToString:@"title"]) {
               self.title = obj;
            }
            if ([key isEqualToString:@"pageTitle"]) {
                self.pageTitle = obj;
            }
            if ([key isEqualToString:@"actioneStr"]) {
               self.actioneStr = obj;
            }
            if ([key isEqualToString:@"timeStamp"]) {
                self.timeStamp = obj;
            }
//            if ([key isEqualToString:@"alpha"]) {
//                _alpha = @"mobile";
//            }
//            if ([key isEqualToString:@"frame"]) {
//                _frame = @"mobile";
//            }
        }];
    }
    return self;
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:self.eventType forKey:@"eventType"];
    [dict setValue:self.ViewPath forKey:@"ViewPath"];
    [dict setValue:self.eventID forKey:@"eventID"];
    [dict setValue:self.title forKey:@"title"];
    [dict setValue:self.pageTitle forKey:@"pageTitle"];
    [dict setValue:self.actioneStr forKey:@"actioneStr"];
    [dict setValue:self.timeStamp forKey:@"timeStamp"];
//    [dict setValue:self.timeStamp forKey:@"alpha"];
//    [dict setValue:self.timeStamp forKey:@"frame"];
    
    return dict;
}

- (NSString *)toJSON
{
    NSError *error = nil;
    NSDictionary *dict = [self toDictionary];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    
    if (error != nil) {
        return nil;
    }
    else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return jsonString;
    }
}

@end
