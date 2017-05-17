//
//  XIActionSheet.h
//  XIAlertView
//
//  Created by YXLONG on 2017/5/16.
//  Copyright © 2017年 yxlong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, XIActionSheetActionStyle) {
    XIActionSheetButtonStyleDefault = 0,
    //XIActionSheetButtonStyleCancel,
    XIActionSheetButtonStyleDestructive
};

@class XIActionSheetButtonItem;
@interface XIActionSheet : UIView
- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
            cancelButtonTitle:(NSString *)cancelButtonTitle;

- (void)addButtonWithTitle:(NSString *)title
                     style:(XIActionSheetActionStyle)style
                   handler:(void(^)(XIActionSheet *actionSheet, XIActionSheetButtonItem *buttonItem))handler;
- (void)addDefaultStyleButtonWithTitle:(NSString *)title
                               handler:(void(^)(XIActionSheet *actionSheet, XIActionSheetButtonItem *buttonItem))handler;

- (void)show;// Show the ActionSheet on visible window.
- (void)showInView:(UIView *)view;
- (void)dismiss;// Removed from its parent view.

+ (void)remove;// Remove the ActionSheet on visible window.
+ (void)removeOnView:(UIView *)view;
@end
