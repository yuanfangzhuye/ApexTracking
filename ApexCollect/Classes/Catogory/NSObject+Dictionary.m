//
//  NSObject+Dictionary.m
//  ApexCollect
//
//  Created by yulin chi on 2018/10/23.
//  Copyright © 2018 yulin chi. All rights reserved.
//

#import "NSObject+Dictionary.h"
#import <objc/runtime.h>

@implementation NSObject (Dictionary)
- (NSMutableDictionary *)toDict{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    unsigned int ivarCount = 0;
    Ivar *ivarList = class_copyIvarList(self.class, &ivarCount);
    
    @try {
        for (int i = 0; i < ivarCount; i ++) {
            Ivar ivar = ivarList[i];
            char *name = ivar_getName(ivar);
            NSString *key = [NSString stringWithUTF8String:name];
            id value = [self valueForKey:key];
            if (value) {
                [dict setValue:value forKey:key];
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    
    return dict;
}
@end
