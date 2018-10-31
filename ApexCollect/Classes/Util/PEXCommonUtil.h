//
//  PEXCommonUtil.h
//  ChinapexAnalytics
//
//  Created by Cedric Wu on 2017/7/20.
//  Copyright © 2017年 Cedric Wu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PEXCommonUtil : NSObject

#pragma mark - 蓝牙相关
+ (NSString *)getBluetoothMAC;

#pragma mark - IP相关
+ (NSString *)getIPAddress:(BOOL)preferIPv4;

#pragma mark - 正则表达式相关
+ (BOOL)match:(NSString *)str withRegex:(NSString *)regexString;

+ (BOOL)isVaildUrl:(NSString *)str;

#pragma mark - Bundle
+ (NSBundle *)getBundle;
+ (NSString *)getDocumentsDirectory;
+ (BOOL)isPathExist:(NSString *)path;
+ (void)createFileAt:(NSString *)path;
+ (NSData *)loadFileAt:(NSString *)path;

#pragma mark - Localized String
+ (NSString *)getLocalizedStringBy:(NSString *)key;

#pragma mark - UIViewController
+ (UIViewController *)getCurrentVC:(UIView*)view;
+ (UIViewController *)topViewController;
+ (UIViewController *)viewControllerOfView:(UIView*)view;

#pragma mark - UIView
+ (UITableView*)tableViewForCell:(UITableViewCell*)cell;
+ (UICollectionView *)collctionViewForItem:(UICollectionViewCell*)item;


#pragma mark - NetWork

/**
 获取当前网络状
 */
+ (NSString *)getNetType;

+ (NSArray *)splitArray: (NSArray *)array withSubSize : (int)subSize;
@end
