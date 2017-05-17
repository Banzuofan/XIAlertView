//
//  XIActionSheetHeaderView.h
//  XIAlertView
//
//  Created by YXLONG on 2017/5/16.
//  Copyright © 2017年 yxlong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XIActionSheetHeaderView : UIView
@property(nonatomic) CGFloat preferredMaxLayoutWidth;
- (void)setTitle:(NSString *)title;
- (void)setMessage:(NSString *)message;
@end
