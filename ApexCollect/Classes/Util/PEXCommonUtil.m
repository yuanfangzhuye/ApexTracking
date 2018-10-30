//
//  PEXCommonUtil.m
//  ChinapexAnalytics
//
//  Created by Cedric Wu on 2017/7/20.
//  Copyright © 2017年 Cedric Wu. All rights reserved.
//

#import "PEXCommonUtil.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>
#import "Reachability.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
//#define IOS_VPN       @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

static UIViewController *currentViewController = nil;

@implementation PEXCommonUtil

#pragma mark - 蓝牙相关
+ (NSString *)getBluetoothMAC {
//    CBUUID *macServiceUUID = [CBUUID UUIDWithString:@"180A"];
//    CBUUID *macCharcteristicUUID = [CBUUID UUIDWithString:@"2A23"];
//    [mPeripheral discoverServices:@[macServiceUUID] withBlock:^(MPPeripheral *peripheral, NSError *error) {
//        if(peripheral.services.count){
//            MPService *service = [peripheral.services objectAtIndex:0];
//            [service discoverCharacteristics:@[macCharcteristicUUID] withBlock:^(MPPeripheral *peripheral, MPService *service, NSError *error) {
//                for(MPCharacteristic *characteristic in service.characteristics){
//                    if([characteristic.UUID isEqual:macCharcteristicUUID]){
//                        [characteristic readValueWithBlock:^(MPPeripheral *peripheral, MPCharacteristic *characteristic, NSError *error){
//                            NSString *value = [NSString stringWithFormat:@"%@",characteristic.value];
//                            NSMutableString *macString = [[NSMutableString alloc] init];
//                            [macString appendString:[[value substringWithRange:NSMakeRange(16, 2)] uppercaseString]];
//                            [macString appendString:@":"];
//                            [macString appendString:[[value substringWithRange:NSMakeRange(14, 2)] uppercaseString]];
//                            [macString appendString:@":"];
//                            [macString appendString:[[value substringWithRange:NSMakeRange(12, 2)] uppercaseString]];
//                            [macString appendString:@":"];
//                            [macString appendString:[[value substringWithRange:NSMakeRange(5, 2)] uppercaseString]];
//                            [macString appendString:@":"];
//                            [macString appendString:[[value substringWithRange:NSMakeRange(3, 2)] uppercaseString]];
//                            [macString appendString:@":"];
//                            [macString appendString:[[value substringWithRange:NSMakeRange(1, 2)] uppercaseString]];
//                            NSLog(@"macString:%@",macString);
//                        }];
//                    }
//                }
//            }];
//        }
//    }];
    return @"";
}

#pragma mark - IP相关
+ (NSString *)getIPAddress:(BOOL)preferIPv4 {
    NSArray *searchArray = preferIPv4 ?
    @[ /*IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6,*/ IOS_WIFI @"/"
    IP_ADDR_IPv4, IOS_WIFI
    @"/"
    IP_ADDR_IPv6, IOS_CELLULAR
    @"/"
    IP_ADDR_IPv4, IOS_CELLULAR
    @"/"
    IP_ADDR_IPv6 ] :
    @[ /*IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4,*/ IOS_WIFI @"/"
    IP_ADDR_IPv6, IOS_WIFI
    @"/"
    IP_ADDR_IPv4, IOS_CELLULAR
    @"/"
    IP_ADDR_IPv6, IOS_CELLULAR
    @"/"
    IP_ADDR_IPv4 ];

    NSDictionary *addresses = [self getIPAddresses];
    NSLog(@"addresses: %@", addresses);

    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        address = addresses[key];
        if (address) *stop = YES;
    }];
    return address ? address : @"0.0.0.0";
}

+ (NSDictionary *)getIPAddresses {
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];

    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if (!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for (interface = interfaces; interface; interface = interface->ifa_next) {
            if (!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in *) interface->ifa_addr;
            char addrBuf[MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN)];
            if (addr && (addr->sin_family == AF_INET || addr->sin_family == AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if (addr->sin_family == AF_INET) {
                    if (inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6 *) interface->ifa_addr;
                    if (inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if (type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

#pragma mark - 正则表达式相关
+ (BOOL)match:(NSString *)str withRegex:(NSString *)regexString {
    NSError *error;

    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:&error];
    if (error != nil) {
        return NO;
    } else {
        NSTextCheckingResult *match = [regex firstMatchInString:str options:NSMatchingReportCompletion range:NSMakeRange(0, [str length])];
        if (match) {
            return YES;
        } else {
            return NO;
        }
    }
}

+ (BOOL)isVaildUrl:(NSString *)str {
//    return [self match:str withRegex:@"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)"];
    return YES;
}

#pragma mark - Bundle

+ (NSBundle *)getBundle {
    NSBundle *bundle = [NSBundle bundleForClass:[PEXCommonUtil class]];
    return bundle;
}

+ (NSString *)getDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if (paths.count > 0) {
        NSString *basePath = paths.firstObject;
        return basePath;
    } else {
        return nil;
    }
}

+ (BOOL)isPathExist:(NSString *)path {
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+ (void)createFileAt:(NSString *)path {
    [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
}

+ (NSData *)loadFileAt:(NSString *)path {
    return [[NSFileManager defaultManager] contentsAtPath:path];
}

#pragma mark - Localized String

+ (NSString *)getLocalizedStringBy:(NSString *)key {
    NSBundle *bundle = [PEXCommonUtil getBundle];
    NSString *str = [bundle localizedStringForKey:key value:nil table:nil];
    return str;
}

#pragma mark - UIViewController
+ (UIViewController *)getCurrentVC:(UIView*)view{
    
    UIResponder *responder = [view nextResponder];
    while (responder && ![responder isKindOfClass:[UIViewController class]]) {
        responder = [responder nextResponder];
    }
    
    if ([responder isKindOfClass:UIViewController.class]) {
        return (UIViewController*)responder;
    }
    
    return nil;
}

+ (UIViewController *)viewControllerOfView:(UIView *)view{
    return [self getCurrentVC:view];
}

+ (UIViewController *)topViewController {
    UIViewController *resultVC;
    resultVC = [self _topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

+ (UIViewController *)_topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}

+ (UITableView *)tableViewForCell:(UITableViewCell *)cell{
    UITableView *tableView = nil;
    UIView *superView = cell.superview;
    while (superView) {
        if ([superView isKindOfClass:UITableView.class]) {
            tableView = (UITableView*)cell.superview;
            break;
        }
        superView = superView.superview;
    }
    return tableView;
}

+ (UICollectionView *)collctionViewForItem:(UICollectionViewCell*)item{
    UICollectionView *collectionView = nil;
    UIView *superView = item.superview;
    while (superView) {
        if ([superView isKindOfClass:[UICollectionView class]]) {
            collectionView = (UICollectionView*)superView;
            break;
        }
        superView = superView.superview;
    }
    return collectionView;
}

//+ (PEXNetWorkStatus)getCurrentNetworkStatus{
//    
//    PEXNetWorkStatus status = PEXNetWorkStatus_NotReachable;
//    Reachability *reachability   = [Reachability reachabilityWithHostName:@"www.apple.com"];
//    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
//    
//    switch (internetStatus) {
//        case ReachableViaWiFi:
//            status = PEXNetWorkStatus_WIFI;
//            break;
//            
//        case ReachableViaWWAN:{
//            NSString *netStr = [self getNetType];
//            if ([netStr isEqualToString:@"4G"]) {
//                status = PEXNetWorkStatus_4G;
//            }else if ([netStr containsString:@"3G"]){
//                status = PEXNetWorkStatus_3G;
//            }else if ([netStr containsString:@"2G"]){
//                status = PEXNetWorkStatus_2G;
//            }else if ([netStr isEqualToString:@"GPRS"]){
//                status = PEXNetWorkStatus_GPRS;
//            }else{
//                status = PEXNetWorkStatus_UNKNOW;
//            }
//        }
//            break;
//            
//        case NotReachable:
//            status = PEXNetWorkStatus_NotReachable;
//        default:
//            break;
//    }
//    
//    return status;
//}

+ (NSString *)getNetType
{
    NSString *netconnType = @"";
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    NSString *currentStatus = info.currentRadioAccessTechnology;
    if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyGPRS"]) {
        netconnType = @"GPRS";
    }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyEdge"]) {
        netconnType = @"2G";
    }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyWCDMA"]){
        netconnType = @"3G";
    }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSDPA"]){
        netconnType = @"3G";
    }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSUPA"]){
        netconnType = @"3G";
    }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMA1x"]){
        netconnType = @"2G";
    }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORev0"]){
        netconnType = @"3G";
    }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevA"]){
        netconnType = @"3G";
    }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevB"]){
        netconnType = @"3G";
    }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyeHRPD"]){
        netconnType = @"HRPD";
    }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyLTE"]){
        netconnType = @"4G";
    }
    
    return netconnType;
}



/**
 *  将数组拆分成固定长度的子数组
 *
 *  @param array 需要拆分的数组
 *
 *  @param subSize 指定长度
 *
 */
+ (NSArray *)splitArray: (NSArray *)array withSubSize : (int)subSize{
    //  数组将被拆分成指定长度数组的个数
    unsigned long count = array.count % subSize == 0 ? (array.count / subSize) : (array.count / subSize + 1);
    //  用来保存指定长度数组的可变数组对象
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    //利用总个数进行循环，将指定长度的元素加入数组
    for (int i = 0; i < count; i ++) {
        //数组下标
        int index = i * subSize;
        //保存拆分的固定长度的数组元素的可变数组
        NSMutableArray *arr1 = [[NSMutableArray alloc] init];
        //移除子数组的所有元素
        [arr1 removeAllObjects];
        
        int j = index;
        //将数组下标乘以1、2、3，得到拆分时数组的最大下标值，但最大不能超过数组的总大小
        while (j < subSize*(i + 1) && j < array.count) {
            [arr1 addObject:[array objectAtIndex:j]];
            j += 1;
        }
        //将子数组添加到保存子数组的数组中
        [arr addObject:[arr1 copy]];
    }
    
    return [arr copy];
}

@end
