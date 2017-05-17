//
//  XIBlurView.h
//  XIAlertView
//
//  Created by YXLONG on 2017/5/17.
//  Copyright © 2017年 yxlong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XIBlurView : UIView
@property(nonatomic, strong) UIView *backgroundView;
@property(nonatomic, strong) UIVisualEffectView *blurView;
- (void)applyBlurEffect;
- (void)disableBlurEffect;
@end
