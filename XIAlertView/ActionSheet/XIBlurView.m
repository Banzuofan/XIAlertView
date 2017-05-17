//
//  XIBlurView.m
//  XIAlertView
//
//  Created by YXLONG on 2017/5/17.
//  Copyright © 2017年 yxlong. All rights reserved.
//

#import "XIBlurView.h"

@implementation XIBlurView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if (!_backgroundView) {
            _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
            _backgroundView.alpha = 1.0;
            _backgroundView.backgroundColor = [UIColor whiteColor];
            [self addSubview:_backgroundView];
        }
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _blurView.frame = self.bounds;
    _backgroundView.frame = self.bounds;
}

- (void)applyBlurEffect{
    
    self.backgroundColor = [UIColor clearColor];
    if(!_blurView){
        _blurView = [[UIVisualEffectView alloc] initWithFrame:self.bounds];
        _blurView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        [self addSubview:_blurView];
        [self sendSubviewToBack:_blurView];
    }
    _backgroundView.alpha = 0.25;
}

- (void)disableBlurEffect
{
    _backgroundView.alpha = 0.98;
    if(_blurView){
        [_blurView removeFromSuperview];
        _blurView = nil;
    }
}

@end
