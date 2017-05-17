//
//  XIActionSheetButtonItem.h
//  XIAlertView
//
//  Created by YXLONG on 2017/5/17.
//  Copyright © 2017年 yxlong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XIActionSheet;
@class XIBlurView;
@interface XIActionSheetButtonItem : UIButton
@property(nonatomic, weak) XIActionSheet *actionSheet;
@property(nonatomic, strong) XIBlurView *backgroundView;
@property(nonatomic, assign) BOOL blurEnabled;
@property(nonatomic, copy) void(^actionHanlder)(XIActionSheet *actionSheet, XIActionSheetButtonItem *buttonItem);
@end
