//
//  PEXMethodSwizzlingUtil.h
//  ChinapexAnalytics
//
//  Created by Cedric Wu on 2017/7/20.
//  Copyright © 2017年 Cedric Wu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface PEXMethodSwizzlingUtil : NSObject

+ (void)methodSwizzle:(Class)clazz origin:(SEL)originSel new:(SEL)newSel;
+ (void)methodSwizzle:(Class)clazz otherClass:(Class)otherClass origin:(SEL)originSel new:(SEL)newSel;
@end
