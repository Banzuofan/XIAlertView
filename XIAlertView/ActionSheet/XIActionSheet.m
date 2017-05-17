//
//  XIActionSheet.m
//  XIAlertView
//
//  Created by YXLONG on 2017/5/16.
//  Copyright © 2017年 yxlong. All rights reserved.
//

#import "XIActionSheet.h"
#import "XIActionSheetHeaderView.h"
#import "XIActionSheetButtonItem.h"
#import "XIActionSheetBackgroundView.h"
#import "XIBlurView.h"

CGFloat kCornerRadius = 8;
CGFloat kButtonHeight = 45;

#define kTopMinSpace 30.0
#define kCommonSpace 10.0
#define kButtonLineSpace 0.5
#define kExpendingHeight 500
#define kButtonTitleColor [UIColor colorWithRed:0.0f green:0.5f blue:1.0f alpha:1.0f]
#define kDestructiveButtonTitleColor [UIColor colorWithRed:0.988 green:0.239 blue:0.224 alpha:1.00]
#define kScreenWidth CGRectGetWidth([UIScreen mainScreen].bounds)
#define kScreenHeight CGRectGetHeight([UIScreen mainScreen].bounds)

@interface XIActionSheet ()
{
    UIView *_contentView;
    XIBlurView *_textScrollBackgroundView;
    UIScrollView *_textScrollView;
    UIScrollView *_buttonsScrollView;
    XIActionSheetHeaderView * _actionSheetHeaderView;
    
    NSMutableArray *_buttons;
    XIActionSheetButtonItem *_cancelButton;
    
    XIActionSheetBackgroundView *_backgroundView;
}
@end

@implementation XIActionSheet

- (void)dealloc
{
    NSLog(@"%s", __FUNCTION__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (void)initialize
{
    if (self == [XIActionSheet class]) {
    
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            if([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0f){
                kCornerRadius = 12;
                kButtonHeight = 58;
            }
        });
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self=[super initWithFrame:frame]){
        _buttons = @[].mutableCopy;
        
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0)];
        [self addSubview:_contentView];
        _contentView.layer.cornerRadius = kCornerRadius;
        _contentView.clipsToBounds = YES;
        
        _buttonsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _contentView.frame.size.width, 0)];
        _buttonsScrollView.backgroundColor = [UIColor clearColor];
        _buttonsScrollView.clipsToBounds = YES;
        [_contentView addSubview:_buttonsScrollView];
        
        _textScrollBackgroundView = [[XIBlurView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0)];
        [_contentView addSubview:_textScrollBackgroundView];
        
        _textScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _contentView.frame.size.width, 0)];
        _textScrollView.backgroundColor = [UIColor clearColor];
        [_contentView addSubview:_textScrollView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle
{
    if(self=[self initWithFrame:CGRectZero]){
        
        _actionSheetHeaderView = [[XIActionSheetHeaderView alloc] initWithFrame:CGRectZero];
        [_actionSheetHeaderView setTitle:title];
        [_actionSheetHeaderView setMessage:message];
        _actionSheetHeaderView.preferredMaxLayoutWidth = kScreenWidth - kCommonSpace*2;
        [_textScrollView addSubview:_actionSheetHeaderView];
        _actionSheetHeaderView.translatesAutoresizingMaskIntoConstraints = NO;
        [_actionSheetHeaderView setContentHuggingPriority:751 forAxis:0];
        [_actionSheetHeaderView setContentHuggingPriority:751 forAxis:1];
        
        NSArray *arr =  @[[NSLayoutConstraint constraintWithItem:_actionSheetHeaderView
                                                       attribute:NSLayoutAttributeCenterX
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:_textScrollView
                                                       attribute:NSLayoutAttributeCenterX
                                                      multiplier:1
                                                        constant:0],
                          [NSLayoutConstraint constraintWithItem:_actionSheetHeaderView
                                                       attribute:NSLayoutAttributeTop
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:_textScrollView
                                                       attribute:NSLayoutAttributeTop
                                                      multiplier:1
                                                        constant:0]];
        [_textScrollView addConstraints:arr];
        
        if(cancelButtonTitle && cancelButtonTitle.length>0){
            _cancelButton = [[XIActionSheetButtonItem alloc] initWithFrame:CGRectZero];
            _cancelButton.backgroundColor = [UIColor whiteColor];
            _cancelButton.blurEnabled = NO;
            _cancelButton.actionSheet = self;
            _cancelButton.actionHanlder = ^(XIActionSheet *actionSheet, XIActionSheetButtonItem *buttonItem) {
                [actionSheet dismiss];
            };
            [_cancelButton setTitle:cancelButtonTitle forState:UIControlStateNormal];
            [_cancelButton setTitleColor:kButtonTitleColor forState:UIControlStateNormal];
            _cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:_cancelButton.titleLabel.font.pointSize];
            [self addSubview:_cancelButton];
            
            _cancelButton.layer.cornerRadius = kCornerRadius;
            _cancelButton.clipsToBounds = YES;
            
            _cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
            
            arr =  @[[NSLayoutConstraint constraintWithItem:_cancelButton
                                                  attribute:NSLayoutAttributeWidth
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self
                                                  attribute:NSLayoutAttributeWidth
                                                 multiplier:1
                                                   constant:0],
                     [NSLayoutConstraint constraintWithItem:_cancelButton
                                                  attribute:NSLayoutAttributeHeight
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:nil
                                                  attribute:0
                                                 multiplier:1
                                                   constant:kButtonHeight],
                     [NSLayoutConstraint constraintWithItem:_cancelButton
                                                  attribute:NSLayoutAttributeBottom
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self
                                                  attribute:NSLayoutAttributeBottom
                                                 multiplier:1
                                                   constant:-kCommonSpace],
                     [NSLayoutConstraint constraintWithItem:_cancelButton
                                                  attribute:NSLayoutAttributeCenterX
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self
                                                  attribute:NSLayoutAttributeCenterX
                                                 multiplier:1
                                                   constant:0]];
            
            [self addConstraints:arr];
        }
        
        [self updateLayouts];
    }
    return self;
}

- (void)orientationDidChange
{
    _actionSheetHeaderView.preferredMaxLayoutWidth = kScreenWidth-kCommonSpace*2;
    
    if(_backgroundView){
        CGRect tmpRect = [self convertRect:_contentView.frame toView:self.superview];
        _backgroundView.cropRect = tmpRect;
    }
    
    [self updateLayouts];
}

- (void)updateLayouts
{
    CGFloat contentViewBottomMargin = kCommonSpace;
    CGFloat contianerWidth = kScreenWidth - kCommonSpace*2;
    
    if(_cancelButton){
        contentViewBottomMargin = kButtonHeight + kCommonSpace*2;
    }
    
    CGFloat totalButtonsHeight = 0;
    if(_buttons.count>0){
        
        UIView *lastView = nil;
        for(XIActionSheetButtonItem *btn in _buttons){
            if(lastView){
                btn.frame = CGRectMake(0, CGRectGetMaxY(lastView.frame)+kButtonLineSpace, contianerWidth, kButtonHeight);
                
                CGRect rect = btn.backgroundView.frame;
                rect.size.height = CGRectGetHeight(btn.frame);
                btn.backgroundView.frame = rect;
            }
            else{
                btn.frame = CGRectMake(0, kButtonLineSpace, contianerWidth, kButtonHeight);
                
                CGRect rect = btn.backgroundView.frame;
                rect.origin.y = -kExpendingHeight+kButtonHeight;
                rect.size.height = kExpendingHeight;
                btn.backgroundView.frame = rect;
            }
            
            lastView = btn;
        }
        
        if(lastView){
            XIActionSheetButtonItem *btn = (XIActionSheetButtonItem *)lastView;
            CGRect rect = btn.backgroundView.frame;
            rect.size.height = kButtonHeight+kExpendingHeight;
            btn.backgroundView.frame = rect;
            
            totalButtonsHeight = CGRectGetMaxY(lastView.frame);
        }
    }
    
    CGFloat maxContentViewHeight = kScreenHeight-kTopMinSpace-contentViewBottomMargin;
    
    if(totalButtonsHeight>0){
        if(_actionSheetHeaderView.intrinsicContentSize.height+totalButtonsHeight>maxContentViewHeight){
            
            if(_actionSheetHeaderView.intrinsicContentSize.height+kButtonHeight*2<=maxContentViewHeight){
                
                _textScrollView.frame = CGRectMake(0, 0, contianerWidth, _actionSheetHeaderView.intrinsicContentSize.height);
                
                
                _buttonsScrollView.frame = CGRectMake(0, CGRectGetMaxY(_textScrollView.frame)+kButtonLineSpace, contianerWidth, maxContentViewHeight-_actionSheetHeaderView.intrinsicContentSize.height);
                [_buttonsScrollView setContentSize:CGSizeMake(contianerWidth, totalButtonsHeight)];
            }
            else{
                _textScrollView.frame = CGRectMake(0, 0, contianerWidth, maxContentViewHeight-kButtonHeight*2);
                [_textScrollView setContentSize:CGSizeMake(contianerWidth, _actionSheetHeaderView.intrinsicContentSize.height)];
                
                _buttonsScrollView.frame = CGRectMake(0, CGRectGetMaxY(_textScrollView.frame)+kButtonLineSpace, contianerWidth, kButtonHeight*2);
                [_buttonsScrollView setContentSize:CGSizeMake(contianerWidth, totalButtonsHeight)];
            }
        }
        else{
            _textScrollView.frame = CGRectMake(0, 0, contianerWidth, _actionSheetHeaderView.intrinsicContentSize.height);
            
            _buttonsScrollView.frame = CGRectMake(0, CGRectGetMaxY(_textScrollView.frame)+kButtonLineSpace, contianerWidth, totalButtonsHeight);
        }
    }
    else{
        if(_actionSheetHeaderView.intrinsicContentSize.height>maxContentViewHeight){
            _textScrollView.frame = CGRectMake(0, 0, contianerWidth, maxContentViewHeight);
            [_textScrollView setContentSize:CGSizeMake(contianerWidth, _actionSheetHeaderView.intrinsicContentSize.height)];
        }
        else{
            _textScrollView.frame = CGRectMake(0, 0, contianerWidth, _actionSheetHeaderView.intrinsicContentSize.height);
        }
    }
    
    _textScrollBackgroundView.frame = _textScrollView.frame;
    
    // Set frame of _contentView.
    CGFloat contentViewHeight = CGRectGetHeight(_textScrollView.frame)+CGRectGetHeight(_buttonsScrollView.frame);
    _contentView.frame = CGRectMake(0, 0, CGRectGetWidth(_textScrollView.frame), contentViewHeight);
    
    // Set frame of actionSheet.
    self.frame = CGRectMake(kCommonSpace, kScreenHeight-CGRectGetHeight(_contentView.frame)-contentViewBottomMargin, kScreenWidth - kCommonSpace*2, CGRectGetHeight(_contentView.frame)+contentViewBottomMargin);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self updateLayouts];
}

- (void)addButtonWithTitle:(NSString *)title
                     style:(XIActionSheetActionStyle)style
                   handler:(void(^)(XIActionSheet *actionSheet, XIActionSheetButtonItem *buttonItem))handler
{
    if(title && title.length>0){
        
        XIActionSheetButtonItem *button = [[XIActionSheetButtonItem alloc] initWithFrame:CGRectZero];
        button.actionSheet = self;
        button.actionHanlder = ^(XIActionSheet *actionSheet, XIActionSheetButtonItem *buttonItem) {
            [actionSheet dismiss];
            if(handler){
                handler(actionSheet, buttonItem);
            }
        };
        [button setTitle:title forState:UIControlStateNormal];
        if(style==XIActionSheetButtonStyleDefault){
            [button setTitleColor:kButtonTitleColor forState:UIControlStateNormal];
        }
        else if(style==XIActionSheetButtonStyleDestructive){
            [button setTitleColor:kDestructiveButtonTitleColor forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont boldSystemFontOfSize:_cancelButton.titleLabel.font.pointSize];
        }
        [_buttonsScrollView addSubview:button];
        
        [_buttons addObject:button];
    }
    
    [self updateLayouts];
}

- (void)addDefaultStyleButtonWithTitle:(NSString *)title
                               handler:(void(^)(XIActionSheet *actionSheet, XIActionSheetButtonItem *buttonItem))handler
{
    [self addButtonWithTitle:title
                       style:XIActionSheetButtonStyleDefault
                     handler:handler];
}

- (void)showInView:(UIView *)view
{
    XIActionSheet *viewToRemove = nil;
    for(UIView *elem in view.subviews){
        if([elem isKindOfClass:[XIActionSheet class]]){
            viewToRemove = (XIActionSheet *)elem;
            break;
        }
    }
    if(viewToRemove){
        [viewToRemove removeFromSuperview];
        viewToRemove = nil;
    }
    
    [view addSubview:self];
    
    if(!_backgroundView){
        _backgroundView = [[XIActionSheetBackgroundView alloc] initWithFrame:view.bounds];
        [view insertSubview:_backgroundView belowSubview:self];
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        _backgroundView.fillColor = [UIColor colorWithWhite:0 alpha:0.35];
        
        [_backgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)]];
    }
    
    self.transform = CGAffineTransformMakeTranslation(0, view.frame.size.height);
    _backgroundView.alpha = 0;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.transform = CGAffineTransformIdentity;
        _backgroundView.alpha = 1;
    } completion:^(BOOL finished) {
        [self->_textScrollBackgroundView applyBlurEffect];
        
        for(XIActionSheetButtonItem *elem in _buttons){
            [elem.backgroundView applyBlurEffect];
        }
        
        if(_backgroundView){
            CGRect tmpRect = [self convertRect:_contentView.frame toView:view];
            _backgroundView.cropRect = tmpRect;
        }
    }];
}

- (void)show
{
    [self showInView:[XIActionSheet visibleWindow]];
}

- (void)dismiss
{
    [XIActionSheet removeOnView:self.superview];
}

+ (void)removeOnView:(UIView *)view
{
    __block XIActionSheet *viewToRemove = nil;
    for(UIView *elem in view.subviews){
        if([elem isKindOfClass:[XIActionSheet class]]){
            viewToRemove = (XIActionSheet *)elem;
            break;
        }
    }
    
    if(viewToRemove){
        [viewToRemove->_textScrollBackgroundView disableBlurEffect];
        for(XIActionSheetButtonItem *elem in viewToRemove->_buttons){
            [elem.backgroundView disableBlurEffect];
        }
        if(viewToRemove->_backgroundView){
            viewToRemove->_backgroundView.cropRect = CGRectZero;
        }
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            viewToRemove.transform = CGAffineTransformMakeTranslation(0, viewToRemove.frame.size.height);
            
            if(viewToRemove->_backgroundView){
                viewToRemove->_backgroundView.alpha = 0;
            }
        } completion:^(BOOL finished) {
            if(viewToRemove->_backgroundView){
                [viewToRemove->_backgroundView removeFromSuperview];
                viewToRemove->_backgroundView = nil;
            }
            
            [viewToRemove removeFromSuperview];
            viewToRemove = nil;
        }];
    }
}

+ (void)remove
{
    [XIActionSheet removeOnView:[XIActionSheet visibleWindow]];
}

+ (UIWindow *)visibleWindow
{
    NSArray *windows = [UIApplication sharedApplication].windows;
    UIWindow *w = [UIApplication sharedApplication].keyWindow;
    for(UIWindow *elem in windows){
        if(elem.windowLevel == UIWindowLevelNormal){
            w = elem;
        }
    }
    return w;
}

@end
