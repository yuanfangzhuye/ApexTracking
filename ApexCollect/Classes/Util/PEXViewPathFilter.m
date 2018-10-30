//
//  PEXViewPathFilter.m
//  DataCollector
//
//  Created by yulin chi on 2018/9/27.
//  Copyright © 2018年 yulin chi. All rights reserved.
//

#import "PEXViewPathFilter.h"

@implementation PEXViewPathFilter

+ (NSDictionary*)viewBlackListArr{
    return @{
             @"UIViewControllerWrapperView":@"",
             @"UINavigationTransitionView":@"",
             @"UILayoutContainerView":@"",
             @"UIViewControllerWrapperView":@"",
             @"UITransitionView":@"",
             };
}

+ (BOOL)isViewInBlackListByClass:(NSString*)className{
    return [[self viewBlackListArr].allKeys containsObject:className];
}


@end
