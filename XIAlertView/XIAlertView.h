//
//  XIAlertView.h
//  XIAlertView
//
//  Created by YXLONG on 16/7/21.
//  Copyright © 2016年 yxlong. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, XIAlertActionStyle) {
    XIAlertActionStyleDefault = 0,
    XIAlertActionStyleCancel,
    XIAlertActionStyleDestructive
};

typedef NS_ENUM(NSInteger, XICustomViewPresentationStyle) {
    Default = 0,
    MoveUp,
    MoveDown
};

@class XIAlertButtonItem;
@interface XIAlertView : UIView
@property(nonatomic, strong) UIColor *titleColor UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIFont *titleFont UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIColor *messageColor UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIFont *messageFont UI_APPEARANCE_SELECTOR;

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle;
- (instancetype)initWithCustomView:(UIView *)customView;
- (instancetype)initWithCustomView:(UIView *)customView withPresentationStyle:(XICustomViewPresentationStyle)style;
- (void)addButtonWithTitle:(NSString *)title
                     style:(XIAlertActionStyle)style
                   handler:(void(^)(XIAlertView *alertView, XIAlertButtonItem *buttonItem))handler;
- (void)addDefaultStyleButtonWithTitle:(NSString *)title
                               handler:(void(^)(XIAlertView *alertView, XIAlertButtonItem *buttonItem))handler;
- (void)show;
- (void)dismiss;
@end

@interface XIAlertView (Creations)
+ (instancetype)alertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle;
+ (instancetype)alertWithCustomView:(UIView *)customView withPresentationStyle:(XICustomViewPresentationStyle)style;
@end






