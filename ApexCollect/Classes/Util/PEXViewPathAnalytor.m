//
//  PEXViewPathAnalytor.m
//  ChinapexAnalytics
//
//  Created by chinapex on 2018/3/23.
//  Copyright © 2018年 Gary Chi. All rights reserved.
//

#import "PEXViewPathAnalytor.h"
#import <UIKit/UIKit.h>
#import "PEXCommonUtil.h"
#import "PEXViewPathFilter.h"
#import "PEXEventBasicModel.h"
#import "NSString+MD5.h"

@interface PEXViewPathAnalytor()
@property (nonatomic, strong) NSMutableArray *sameClassArr; /**<子视图 同类归并  */
@end

@implementation PEXViewPathAnalytor

singleM(PathAnalytor)

+ (void)pex_viewPathOfView:(id)view completeHandler:(completeHandler)handler{
   
    __block NSString *viewPath = @"";
    if (![view isKindOfClass:UIView.class]) {
        [[PEXLogger sharedInstance] debug:@"object is not kind of UIView Class"];
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSMutableArray *Parr = [NSMutableArray array];
        NSMutableArray *Iarr = [NSMutableArray array];
    
    @try {
        
        [[PEXViewPathAnalytor sharePathAnalytor] viewPathAnalyzeWithView:view P_Array:Parr I_Array:Iarr currentVC:[PEXCommonUtil getCurrentVC:view]];
        
        NSMutableArray *temp = [NSMutableArray array];
        UIViewController *curVC =[PEXCommonUtil getCurrentVC:view];
        if (!curVC) {
            curVC = [PEXCommonUtil topViewController];
        }
        
        NSString *actionStr = nil;
        
        if (Parr.count == Iarr.count) {
            for (NSInteger i = 0; i < Parr.count; i ++) {
                if (i == 0 && [view isKindOfClass:UIControl.class]) {
                    actionStr = [((UIControl*)view) valueForKeyPath:@"pex_ActionString"];
                    [temp addObject:[NSString stringWithFormat:@"%@(%@)&%@",Parr[i], Iarr[i],actionStr]];
                }else{
                    [temp addObject:[NSString stringWithFormat:@"%@(%@)",Parr[i], Iarr[i]]];
                }
            }
        }
        viewPath = [temp componentsJoinedByString:@"/"];
    
        viewPath = [NSString stringWithFormat:@"%@ => %@(%@)",viewPath,NSStringFromClass(curVC.class),curVC.title];
        
        UIViewController *subVC = [PEXCommonUtil viewControllerOfView:view];
        if (subVC && curVC != subVC) {
            viewPath = [NSString stringWithFormat:@"%@ -> subViewController: %@",viewPath,NSStringFromClass(subVC.class)];
        }
        
        //新建model
        PEXEventBasicModel *model = [self buildEventModelWithActionString:actionStr view:view viewPath:viewPath curVC:curVC];
        
        if (handler) {
            handler(model);
        }
        
        [[PEXLogger sharedInstance] Verbose:[NSString stringWithFormat:@"viewPath:%@",viewPath]];
    } @catch (NSException *exception) {
        
        [[PEXLogger sharedInstance] error:exception];
    }

    });
}


- (void)viewPathAnalyzeWithView:(UIView*)view P_Array:(NSMutableArray*)pArr I_Array:(NSMutableArray*)iArr currentVC:(UIViewController*)vc{
    
    if (view == vc.view || view == nil) {
        return;
    }
    
    NSString *viewClassStr = NSStringFromClass(view.class);
    
    //不计入带_前缀的系统类view
    if ([view isKindOfClass:UIView.class] && ![PEXViewPathFilter isViewInBlackListByClass:viewClassStr]) {
        
        if ([view isKindOfClass:UITableViewCell.class]) {
            //UITableViewCell
            UITableViewCell *cell = (UITableViewCell*)view;
            [pArr addObject:viewClassStr];
            NSIndexPath *index = [[PEXCommonUtil tableViewForCell:cell] indexPathForCell:cell];
            if (index) {
                [iArr addObject:[NSString stringWithFormat:@"%ld:%ld",(long)index.section,(long)index.row]];
            }
            else{
                [iArr addObject:@""];
            }
            
        }else if ([view isKindOfClass:UICollectionViewCell.class]) {
            //UICollectionCell
            UICollectionViewCell *cell = (UICollectionViewCell*)view;
            [pArr addObject:NSStringFromClass(cell.class)];
            NSIndexPath *index = [[PEXCommonUtil collctionViewForItem:cell] indexPathForCell:cell];
            if (index) {
                [iArr addObject:[NSString stringWithFormat:@"%ld:%ld",(long)index.section,(long)index.row]];
            }
            else{
                [iArr addObject:@" "];
            }
            
        }else{
            
            [pArr addObject:NSStringFromClass(view.class)];
            NSArray *subViews = view.superview.subviews;
            [self.sameClassArr removeAllObjects];
            //同类归并 计算同类型的index => UIButton:0/UIButton:1/UILable:0 => UIButton的增删不会更改UILable的路径
            for (UIView *subView in subViews) {
                if ([NSStringFromClass(view.class) isEqualToString:NSStringFromClass(subView.class)]) {
                    [self.sameClassArr addObject:subView];
                }
            }
            
            [iArr addObject:[NSString stringWithFormat:@"%lu",(unsigned long)[_sameClassArr indexOfObject:view]]];
        }
        
        [self viewPathAnalyzeWithView:view.superview P_Array:pArr I_Array:iArr currentVC:vc];
    }
    
}

+ (PEXEventBasicModel*)buildEventModelWithActionString:(NSString*)actStr view:(UIView*)view viewPath:(NSString*)viewPath curVC:(UIViewController*)curVC{
    PEXEventBasicModel *model = [[PEXEventBasicModel alloc] init];
    model.eventType = @" ";
    model.eventID = [NSString MD5ForLower16Bate:viewPath];
    model.ViewPath = viewPath;
    model.pageTitle = curVC.title;
    model.frame = ((UIView*)view).frame;
    model.alpha = ((UIView*)view).alpha;
    model.timeStamp = @([[NSDate date] timeIntervalSince1970]).stringValue;
    if (actStr) model.actioneStr = actStr;
    
    //附加信息
    if ([view isKindOfClass:UIButton.class]) {
        model.title = ((UIButton*)view).currentTitle;
    }
    
    if ([view isKindOfClass:UILabel.class]) {
        model.title = ((UILabel*)view).text;
    }
    
    return model;
}


#pragma mark - getter
- (NSMutableArray *)sameClassArr{
    if (!_sameClassArr) {
        _sameClassArr = [NSMutableArray array];
    }
    return _sameClassArr;
}
@end
