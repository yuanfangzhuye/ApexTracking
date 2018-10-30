//
//  UITableViewCell+PEX.m
//  ChinapexAnalytics
//
//  Created by chinapex on 2018/3/23.
//  Copyright © 2018年 Gary Chi. All rights reserved.
//

#import "UITableViewCell+PEX.h"

const char* kIndexPath = "kIndexPath";

@implementation UITableViewCell (PEX)


#pragma mark - getter setter
- (void)setPex_indexPath:(NSIndexPath *)pex_indexPath{
    objc_setAssociatedObject(self, kIndexPath, pex_indexPath, OBJC_ASSOCIATION_RETAIN);
}

- (NSIndexPath *)pex_indexPath{
    return objc_getAssociatedObject(self, kIndexPath);
}
@end
