//
//  PEXMethodSwizzlingUtil.m
//  ChinapexAnalytics
//
//  Created by Cedric Wu on 2017/7/20.
//  Copyright © 2017年 Cedric Wu. All rights reserved.
//

#import "PEXMethodSwizzlingUtil.h"

@implementation PEXMethodSwizzlingUtil

+(void)methodSwizzle:(Class)clazz origin:(SEL)originSel new:(SEL)newSel {
    Method originalMethod =
    class_getInstanceMethod(clazz, originSel);
    Method swizzledMethod =
    class_getInstanceMethod(clazz, newSel);

    BOOL isAddSuccess =
    class_addMethod(clazz, originSel,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));

    if (isAddSuccess) {
        class_replaceMethod(clazz, newSel,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

+ (void)methodSwizzle:(Class)clazz otherClass:(Class)otherClass origin:(SEL)originSel new:(SEL)newSel{
    Method originalMethod =
    class_getInstanceMethod(clazz, originSel);
    Method swizzledMethod =
    class_getInstanceMethod(otherClass, newSel);
    
    BOOL isAddSuccess =
    class_addMethod(clazz, originSel,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (isAddSuccess) {
        class_replaceMethod(clazz, newSel,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end
