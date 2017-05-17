//
//  XIActionSheetButtonItem.m
//  XIAlertView
//
//  Created by YXLONG on 2017/5/17.
//  Copyright © 2017年 yxlong. All rights reserved.
//

#import "XIActionSheetButtonItem.h"
#import "XIActionSheet.h"
#import "XIBlurView.h"

@implementation XIActionSheetButtonItem

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self=[super initWithFrame:frame]){
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        
        [self addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        _blurEnabled = YES;
        
        _backgroundView = [[XIBlurView alloc] initWithFrame:self.bounds];
        _backgroundView.userInteractionEnabled = NO;
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:_backgroundView];
    }
    return self;
}

- (void)setBlurEnabled:(BOOL)blurEnabled
{
    _blurEnabled = blurEnabled;
    
    if(_blurEnabled){
        if(!_backgroundView){
            _backgroundView = [[XIBlurView alloc] initWithFrame:self.bounds];
            _backgroundView.userInteractionEnabled = NO;
            _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            [self addSubview:_backgroundView];
        }
        
        self.backgroundColor = [UIColor clearColor];
    }
    else{
        if(_backgroundView){
            [_backgroundView removeFromSuperview];
            _backgroundView = nil;
        }
        
        self.backgroundColor = [UIColor whiteColor];
    }
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    if(highlighted){
        if(_backgroundView){
            _backgroundView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:0.65];
            _backgroundView.blurView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        }
        else{
            self.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
        }
    }
    else{
        if(_backgroundView){
            _backgroundView.backgroundColor = [UIColor clearColor];
            _backgroundView.blurView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        }
        else{
            self.backgroundColor = [UIColor whiteColor];
        }
    }
}

- (void)touchUpInside:(UIButton *)btn
{
    if(_actionHanlder){
        _actionHanlder(self.actionSheet, self);
    }
}

@end
