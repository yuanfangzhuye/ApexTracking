//
//  NSString+MD5.h
//  DataCollector
//
//  Created by yulin chi on 2018/10/9.
//  Copyright © 2018 yulin chi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (MD5)
// MD5加密
/*
 *由于MD5加密是不可逆的,多用来进行验证
 */
// 32位小写
+(NSString *)MD5ForLower32Bate:(NSString *)str;
// 32位大写
+(NSString *)MD5ForUpper32Bate:(NSString *)str;
// 16为大写
+(NSString *)MD5ForUpper16Bate:(NSString *)str;
// 16位小写
+(NSString *)MD5ForLower16Bate:(NSString *)str;
@end

NS_ASSUME_NONNULL_END
