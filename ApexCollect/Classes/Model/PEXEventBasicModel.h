//
//  PEXEventBasicModel.h
//  DataCollector
//
//  Created by yulin chi on 2018/9/28.
//  Copyright © 2018年 yulin chi. All rights reserved.
//

#import "PEXBaseModel.h"

@interface PEXEventBasicModel : PEXBaseModel
//@property (nonatomic, strong) NSString *DeviceName; /**< 设备的类型 */
//@property (nonatomic, strong) NSString *OS; /**< 设备的操作系统 */
//@property (nonatomic, strong) NSString *OSVersion; /**< 操作系统版本 */
//@property (nonatomic, assign) CGRect deviceFrame; /**< 设备的frame */

@property (nonatomic, copy) NSString *eventType; /**< 事件的类型 */
@property (nonatomic, copy) NSString *ViewPath; /**< view路径 */
@property (nonatomic, copy) NSString *eventID; /**< 事件的id MD5(ViewPath) */
@property (nonatomic, assign) CGRect frame; /**< 控件的frame */
@property (nonatomic, copy) NSString *title; /**< 控件的title */
@property (nonatomic, copy) NSString *pageTitle; /**< 当前页面的title */
@property (nonatomic, assign) NSInteger alpha; /**< 透明度 */
@property (nonatomic, copy) NSString *actioneStr; /**< 触发action的字符串 */
@property (nonatomic, copy) NSString *timeStamp; /**<  */
@end
