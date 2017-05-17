//
//  XIAlertView.m
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

#import "XIAlertView.h"
#import <objc/runtime.h>
#import "XIAlertModalBackgroundView.h"

static CGFloat const kDefaultContainerWidth = 280.;
static CGFloat const kTitleMessageSpace = 12;
static CGFloat const kAlertContentViewMinHeight = 80.0;
static CGFloat const kAlertButtonHeight = 44.0;
static CGFloat const kMaxMessageHeight = 220;

CGFloat kDefaultCornerRadius = 8;

#define kAlertLineSpace 0.5
#define kButtonTitleColor [UIColor colorWithRed:0.0f green:0.5f blue:1.0f alpha:1.0f]
#define kDestructiveButtonTitleColor [UIColor colorWithRed:0.988 green:0.239 blue:0.224 alpha:1.00]
#define kDefaultAnimationDuration 0.25
#define kDefaultCustomViewSize CGSizeMake(280, 240)

CGSize XIAlertView_SizeOfLabel(NSString *text, UIFont *font, CGSize constraintSize){
    NSDictionary *attrs = @{NSFontAttributeName:font};
    CGSize aSize = [text boundingRectWithSize:constraintSize
                                      options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                   attributes:attrs
                                      context:nil].size;
    return CGSizeMake(aSize.width, aSize.height+2);
}

#define SIZE_LABEL(text, font, constraintSize) XIAlertView_SizeOfLabel(text, font, constraintSize)

@interface UIViewController (__backgroundView)
- (XIAlertModalBackgroundView *)backgroundView;
@end

static void* __backgroundViewKey = &__backgroundViewKey;
@implementation UIViewController (__backgroundView)
- (UIView *)backgroundView
{
    XIAlertModalBackgroundView *v = objc_getAssociatedObject(self, __backgroundViewKey);
    if(!v){
        v = [[XIAlertModalBackgroundView alloc] initWithFrame:self.view.bounds];
        v.autoresizingMask = self.view.autoresizingMask;
        [self.view addSubview:v];
        
        objc_setAssociatedObject(self, __backgroundViewKey, v, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return v;
}
@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

#pragma Mark-- Private classes headers

@interface XIBlurSupportedBackgroundView : UIView
@property(nonatomic, strong) UIView *backgroundView;
@property(nonatomic, strong) UIVisualEffectView *blurView;
- (void)applyBlurEffect;
- (void)disableBlurEffect;
@end

@interface XIAlertButtonItem : UIButton
@property(nonatomic, weak) XIAlertView *alertView;
@property(nonatomic, strong) XIBlurSupportedBackgroundView *backgroundView;
@property(nonatomic, copy) void(^actionHanlder)(XIAlertView *alertView, XIAlertButtonItem *buttonItem);
@end

@interface XIAlertContentView : XIBlurSupportedBackgroundView
@property(nonatomic, weak) XIAlertView *alertView;
@property(nonatomic, strong, readonly) UILabel *titleLabel;
@property(nonatomic, strong, readonly) UILabel *messageLabel;
@property(nonatomic, assign) CGSize preferredFrameSize;
@property(nonatomic, assign) UIEdgeInsets contentInsets;
- (void)setTitle:(NSString *)title message:(NSString *)message;
- (CGSize)getFitSize;
@end

@interface XIAlertViewController : UIViewController
@property (nonatomic, weak) XIAlertView *alertView;
@property (nonatomic, assign) BOOL rootViewControllerPrefersStatusBarHidden;
@property (nonatomic, assign) UIStatusBarStyle rootViewControllerPreferredStatusBarStyle;
@end

@interface XIAlertViewQueue : NSObject
@property(nonatomic, strong) XIAlertView *currentAlertView;
@property(nonatomic, assign, getter=isAnimating) BOOL animating;
+ (instancetype)sharedQueue;
- (BOOL)contains:(XIAlertView *)alertView;
- (XIAlertView *)dequeue;
- (void)enqueue:(XIAlertView *)alertView;
- (void)remove:(XIAlertView *)alertView;
@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@interface XIAlertView ()
{
    XIAlertContentView *_contentView;
}
@property(nonatomic, strong) NSMutableArray *buttons;
@property(nonatomic, strong) UIWindow *lastKeyWindow;
@property(nonatomic, strong) UIWindow *currentKeyWindow;
@property(nonatomic, assign, getter = isVisible) BOOL visible;
@property(nonatomic, assign) BOOL customViewVisible;
@property(nonatomic, assign) XICustomViewPresentationStyle customViewPresentationStyle;
@end

@implementation XIAlertView

+ (void)initialize
{
    if (self == [XIAlertView class]) {
        [XIAlertView appearance].titleColor = [UIColor blackColor];
        [XIAlertView appearance].messageColor = [UIColor blackColor];
        [XIAlertView appearance].titleFont = [UIFont boldSystemFontOfSize:17.0];
        [XIAlertView appearance].messageFont = [UIFont systemFontOfSize:14.0];
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            if([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0f){
                kDefaultCornerRadius = 12;
            }
        });
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self=[super initWithFrame:frame]){
        self.userInteractionEnabled = YES;
        self.layer.cornerRadius = kDefaultCornerRadius;
        self.clipsToBounds = YES;
        
        _buttons = @[].mutableCopy;
    }
    return self;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle
{
    if(self=[self initWithFrame:CGRectZero]){
        
        self.customViewVisible = NO;
        
        _contentView = [[XIAlertContentView alloc] initWithFrame:CGRectZero];
        _contentView.alertView = self;
        _contentView.contentInsets = UIEdgeInsetsMake(20, 15, 20, 15);
        [self addSubview:_contentView];
        [_contentView setTitle:[title copy] message:[message copy]];
        
        if(cancelButtonTitle&&cancelButtonTitle.length>0){
            [self addButtonWithTitle:cancelButtonTitle style:XIAlertActionStyleCancel handler:^(XIAlertView *alertView, XIAlertButtonItem *buttonItem) {
                [alertView dismiss];
            }];
        }
    }
    return self;
}

- (instancetype)initWithCustomView:(UIView *)customView
{
    if(self=[self initWithCustomView:customView withPresentationStyle:Default]){
        
    }
    return self;
}

- (instancetype)initWithCustomView:(UIView *)customView withPresentationStyle:(XICustomViewPresentationStyle)style
{
    if(self=[self initWithFrame:CGRectZero]){
        self.customViewPresentationStyle = style;
        self.customViewVisible = YES;
        
        _contentView = [[XIAlertContentView alloc] initWithFrame:CGRectZero];
        _contentView.alertView = self;
        [self addSubview:_contentView];
        if(CGSizeEqualToSize(customView.frame.size, CGSizeZero)){
            _contentView.preferredFrameSize = kDefaultCustomViewSize;
        }
        else{
            _contentView.preferredFrameSize = customView.frame.size;
        }
        _contentView.frame = CGRectMake(0, 0, _contentView.preferredFrameSize.width, _contentView.preferredFrameSize.height);
        [_contentView addSubview:customView];
        customView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

- (void)addButtonWithTitle:(NSString *)title style:(XIAlertActionStyle)style handler:(void(^)(XIAlertView *alertView, XIAlertButtonItem *buttonItem))handler
{
    if(self.customViewVisible){
        return;
    }
    XIAlertButtonItem *button = [[XIAlertButtonItem alloc] initWithFrame:CGRectZero];
    button.alertView = self;
    button.actionHanlder = handler;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:kButtonTitleColor forState:UIControlStateNormal];
    [self addSubview:button];
    switch (style) {
        case XIAlertActionStyleCancel:
            button.titleLabel.font = [UIFont boldSystemFontOfSize:button.titleLabel.font.pointSize];
            break;
        case XIAlertActionStyleDestructive:
            [button setTitleColor:kDestructiveButtonTitleColor forState:UIControlStateNormal];
            break;
        default:
            break;
    }
    [_buttons addObject:button];
    
    [self updateUILayouts];
}

- (void)addDefaultStyleButtonWithTitle:(NSString *)title handler:(void(^)(XIAlertView *alertView, XIAlertButtonItem *buttonItem))handler
{
    [self addButtonWithTitle:title style:XIAlertActionStyleDefault handler:handler];
}

- (void)updateUILayouts
{
    if(self.customViewVisible){
        return;
    }
    
    CGSize size = [_contentView getFitSize];
    _contentView.frame = CGRectMake(0, 0, kDefaultContainerWidth, size.height);
    
    if(_buttons.count==1){
        XIAlertButtonItem *button = _buttons[0];
        button.frame = CGRectMake(0, CGRectGetMaxY(_contentView.frame)+kAlertLineSpace, kDefaultContainerWidth, kAlertButtonHeight);
    }
    else if(_buttons.count==2){
        
        CGFloat originY = CGRectGetMaxY(_contentView.frame)+kAlertLineSpace;
        
        NSInteger leftItemWidth = (kDefaultContainerWidth-kAlertLineSpace)/2;
        XIAlertButtonItem *button = _buttons[0];
        button.frame = CGRectMake(0, originY, leftItemWidth, kAlertButtonHeight);
        
        CGFloat originX = leftItemWidth + kAlertLineSpace;
        CGFloat rightItemWidth = kDefaultContainerWidth-originX;
        button = _buttons[1];
        button.frame = CGRectMake(originX, originY, rightItemWidth, kAlertButtonHeight);
    }
    else if(_buttons.count>2){
        
        UIView *lastView = _contentView;
        
        for(int i=0;i<_buttons.count;i++){
            XIAlertButtonItem *button = _buttons[i];
            button.frame = CGRectMake(0, CGRectGetMaxY(lastView.frame)+kAlertLineSpace, kDefaultContainerWidth, kAlertButtonHeight);
            lastView = button;
        }
    }
    
    [self invalidateIntrinsicContentSize];
}

- (CGSize)intrinsicContentSize
{
    if(self.customViewVisible){
        return _contentView.frame.size;
    }
    
    CGFloat maxHeight;
    CGSize size = [_contentView getFitSize];
    maxHeight = size.height;
    
    if(_buttons.count<3){
        maxHeight += kAlertButtonHeight+kAlertLineSpace;
    }
    else{
        maxHeight += _buttons.count*(kAlertLineSpace+kAlertButtonHeight);
    }
    return CGSizeMake(kDefaultContainerWidth, maxHeight);
}

- (void)applyBlurEffect
{
    [_contentView applyBlurEffect];
    for(XIAlertButtonItem *item in _buttons){
        [item.backgroundView applyBlurEffect];
    }
}

- (void)disableBlurEffect
{
    [_contentView disableBlurEffect];
    for(XIAlertButtonItem *item in _buttons){
        [item.backgroundView disableBlurEffect];
    }
}

- (void)showWithAnimation:(BOOL)animated completion:(dispatch_block_t)completion
{
    if(animated){
        NSTimeInterval _duration = kDefaultAnimationDuration;
        if(self.currentKeyWindow.rootViewController.view){
            self.currentKeyWindow.rootViewController.backgroundView.alpha = 0;
        }
        if(self.customViewVisible){
            
            if(self.customViewPresentationStyle==Default){
                self.transform = CGAffineTransformMakeScale(1.2, 1.2);
            }
            else if(self.customViewPresentationStyle==MoveUp){
                _duration = 0.35;
                self.transform = CGAffineTransformMakeTranslation(0, [UIScreen mainScreen].bounds.size.height);
            }
            else if (self.customViewPresentationStyle==MoveDown){
                _duration = 0.35;
                self.transform = CGAffineTransformMakeTranslation(0, -[UIScreen mainScreen].bounds.size.height);
            }
        }
        else{
            self.transform = CGAffineTransformMakeScale(1.2, 1.2);
        }
        
        [UIView animateWithDuration:_duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            if(self.customViewVisible){
                if(self.customViewPresentationStyle==Default){
                    
                }
                else if(self.customViewPresentationStyle==MoveUp){
                    
                }
            }
            self.transform = CGAffineTransformIdentity;
            if(self.currentKeyWindow.rootViewController.view){
                self.currentKeyWindow.rootViewController.backgroundView.alpha = 1;
            }
        } completion:^(BOOL finished) {
            if(completion){
                completion();
            }
        }];
    }
    else{
        if(completion){
            completion();
        }
    }
}

- (void)hideWithAnimation:(BOOL)animated completion:(dispatch_block_t)completion
{
    [[XIAlertViewQueue sharedQueue] remove:self];
    self.visible = NO;
    
    // remove the cropped area.
    self.currentKeyWindow.rootViewController.backgroundView.cropSize = CGSizeZero;
    
    if(animated){
        [XIAlertViewQueue sharedQueue].animating = YES;
        NSTimeInterval _duration = kDefaultAnimationDuration;
        if(self.customViewVisible){
            if(self.customViewPresentationStyle==Default){
                
            }
            else if(self.customViewPresentationStyle==MoveUp){
                _duration = 0.35;
            }
            else if (self.customViewPresentationStyle==MoveDown){
                _duration = 0.35;
            }
        }
        else
        {
            [self disableBlurEffect];
        }
        
        [UIView animateWithDuration:_duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            if(self.customViewVisible){
                if(self.customViewPresentationStyle==Default){
                    self.alpha = 0;
                    self.transform = CGAffineTransformMakeScale(0.75,0.75);
                }
                else if(self.customViewPresentationStyle==MoveUp){
                    self.transform = CGAffineTransformMakeTranslation(0, [UIScreen mainScreen].bounds.size.height);
                }
                else if (self.customViewPresentationStyle==MoveDown){
                    self.transform = CGAffineTransformMakeTranslation(0, [UIScreen mainScreen].bounds.size.height);
                }
            }
            else{
                self.alpha = 0;
                self.transform = CGAffineTransformMakeScale(0.8,0.8);
            }
            if(self.currentKeyWindow.rootViewController.view){
                self.currentKeyWindow.rootViewController.backgroundView.alpha = 0;
            }
        } completion:^(BOOL finished) {
            [XIAlertViewQueue sharedQueue].animating = NO;
            [XIAlertViewQueue sharedQueue].currentAlertView = nil;
            if(completion){
                completion();
            }
        }];
    }
    else{
        self.alpha = 0;
        [XIAlertViewQueue sharedQueue].animating = NO;
        [XIAlertViewQueue sharedQueue].currentAlertView = nil;
        if(completion){
            completion();
        }
    }
}

- (void)show
{
    if(_buttons.count==0 && !self.customViewVisible){
        [self addButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:XIAlertActionStyleCancel handler:^(XIAlertView *alertView, XIAlertButtonItem *buttonItem) {
            [alertView dismiss];
        }];
    }
    
    if(![[XIAlertViewQueue sharedQueue] contains:self]){
        [[XIAlertViewQueue sharedQueue] enqueue:self];
    }
    
    if([XIAlertViewQueue sharedQueue].isAnimating){
        return;
    }
    
    if(self.isVisible){
        return;
    }
    
    if([XIAlertViewQueue sharedQueue].currentAlertView.isVisible){
        return;
    }
    
    self.visible = YES;
    [XIAlertViewQueue sharedQueue].currentAlertView = self;
    [XIAlertViewQueue sharedQueue].animating = YES;
    
    self.lastKeyWindow = [UIApplication sharedApplication].keyWindow;
    XIAlertViewController *viewController = [[XIAlertViewController alloc] initWithNibName:nil bundle:nil];
    viewController.alertView = self;
    if ([self.lastKeyWindow.rootViewController respondsToSelector:@selector(prefersStatusBarHidden)]) {
        viewController.rootViewControllerPrefersStatusBarHidden = self.lastKeyWindow.rootViewController.prefersStatusBarHidden;
        viewController.rootViewControllerPreferredStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    }
    if (!self.currentKeyWindow) {
        UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        window.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        window.opaque = NO;
        window.windowLevel = UIWindowLevelAlert;
        window.rootViewController = viewController;
        self.currentKeyWindow = window;
    }
    self.currentKeyWindow.frame = [UIScreen mainScreen].bounds;
    [self.currentKeyWindow makeKeyAndVisible];
    
    // Fix UI issue that the size of alert is less than the size of the cropped area.
    dispatch_block_t _updateAppearance = ^{
        [self updateUILayouts];
        self.currentKeyWindow.rootViewController.backgroundView.cropSize = self.intrinsicContentSize;
    };
    
    _updateAppearance();
    
    [self showWithAnimation:YES completion:^{
        
        _updateAppearance();
        
        [XIAlertViewQueue sharedQueue].animating = NO;
        
        [self applyBlurEffect];
        
    }];
}

- (void)dismiss
{
    [self hideWithAnimation:YES completion:^{
        
        [self removeFromSuperview];
        self.currentKeyWindow.hidden = YES;
        self.currentKeyWindow.rootViewController = nil;
        
        [self.currentKeyWindow removeFromSuperview];
        self.currentKeyWindow = nil;
        
        XIAlertView *nextAlertView = [[XIAlertViewQueue sharedQueue] dequeue];
        if(nextAlertView){
            [nextAlertView show];
        }
    }];
    
    [self.lastKeyWindow makeKeyAndVisible];
    self.lastKeyWindow.hidden = NO;
}

@end

@implementation XIAlertView (Appearance)

- (void)setTitleColor:(UIColor *)titleColor
{
    _titleColor = titleColor;
    if(_contentView){
        _contentView.titleLabel.textColor = _titleColor;
    }
}

- (void)setTitleFont:(UIFont *)titleFont
{
    _titleFont = titleFont;
    if(_contentView){
        _contentView.titleLabel.font = _titleFont;
        
        [_contentView setNeedsUpdateConstraints];
        [_contentView invalidateIntrinsicContentSize];
    }
    [self setNeedsUpdateConstraints];
    [self invalidateIntrinsicContentSize];
}

- (void)setMessageColor:(UIColor *)messageColor
{
    _messageColor = messageColor;
    if(_contentView){
        _contentView.messageLabel.textColor = _messageColor;
    }
}

- (void)setMessageFont:(UIFont *)messageFont
{
    _messageFont = messageFont;
    if(_contentView){
        _contentView.messageLabel.font = _messageFont;
        
        [_contentView setNeedsUpdateConstraints];
        [_contentView invalidateIntrinsicContentSize];
    }
    [self setNeedsUpdateConstraints];
    [self invalidateIntrinsicContentSize];
}

@end

@implementation XIAlertContentView
{
    UILabel *_titleLabel;
    UILabel *_messageLabel;
    NSMutableArray *_constraints;
    BOOL needResize;
    CGSize contentSize;
}
@synthesize titleLabel=_titleLabel;
@synthesize messageLabel=_messageLabel;

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self=[super initWithFrame:frame]){
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor whiteColor];
        _constraints = @[].mutableCopy;
        _preferredFrameSize = CGSizeZero;
    }
    return self;
}

- (UILabel *)titleLabel
{
    if(!_titleLabel){
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 0;
        _titleLabel.font = [XIAlertView appearance].titleFont?:[UIFont boldSystemFontOfSize:17.0f];
        [self addSubview:_titleLabel];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_titleLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
    }
    return _titleLabel;
}

- (UILabel *)messageLabel
{
    if(!_messageLabel){
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.numberOfLines = 0;
        _messageLabel.font = [XIAlertView appearance].messageFont?:[UIFont systemFontOfSize:15.0f];
        [self addSubview:_messageLabel];
        _messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_messageLabel setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];
    }
    return _messageLabel;
}

- (void)setTitle:(NSString *)title message:(NSString *)message
{
    if(![self.titleLabel.text isEqualToString:title] ||
       ![self.messageLabel.text isEqualToString:message]){
        needResize = YES;
    }
    
    if(!title || title.length==0){
        if(message && message.length>0){
            self.titleLabel.text = message;
            self.titleLabel.textColor = [XIAlertView appearance].messageColor?[XIAlertView appearance].messageColor:[UIColor blackColor];
        }
    }
    else{
        self.titleLabel.text = title;
        self.titleLabel.textColor = [XIAlertView appearance].messageColor?[XIAlertView appearance].messageColor:[UIColor blackColor];
        
        self.messageLabel.text = message;
        self.messageLabel.textColor = [XIAlertView appearance].messageColor?[XIAlertView appearance].messageColor:[UIColor blackColor];
    }
    
    [self setNeedsUpdateConstraints];
    [self invalidateIntrinsicContentSize];
}

- (BOOL)isCustomContentView
{
    return !CGSizeEqualToSize(self.preferredFrameSize, CGSizeZero);
}

- (CGSize)intrinsicContentSize
{
    if([self isCustomContentView]){
        return [super intrinsicContentSize];
    }
    return [self getFitSize];
}

- (CGSize)getFitSize
{
    if(!needResize){
        return contentSize;
    }
    
    CGFloat resHeight = 0;
    CGSize aSize;
    CGFloat preferredTextWidth = kDefaultContainerWidth-self.contentInsets.left-self.contentInsets.right;
    if(self.titleLabel.text&&self.titleLabel.text.length>0){
        aSize = SIZE_LABEL(self.titleLabel.text, self.titleLabel.font, CGSizeMake(preferredTextWidth, MAXFLOAT));
        resHeight += aSize.height;
    }
    
    if(self.messageLabel.text&&self.messageLabel.text.length>0){
        aSize = SIZE_LABEL(self.messageLabel.text, self.messageLabel.font, CGSizeMake(preferredTextWidth, MAXFLOAT));
        if(aSize.height>kMaxMessageHeight){
            aSize.height = kMaxMessageHeight;
        }
        resHeight += aSize.height;
    }
    
    if(self.titleLabel.text.length>0&&self.messageLabel.text.length>0){
        resHeight += kTitleMessageSpace;
    }
    resHeight += self.contentInsets.top+self.contentInsets.bottom;
    if(resHeight<kAlertContentViewMinHeight){
        resHeight = kAlertContentViewMinHeight;
    }
    // The resHeight must be rounded, or else it may cause UI issue.
    contentSize = CGSizeMake(kDefaultContainerWidth, round(resHeight));
    
    return contentSize;
}

- (void)setNeedsUpdateConstraints
{
    if([self isCustomContentView]){
        return [super setNeedsUpdateConstraints];
    }
    
    if(_constraints.count>0){
        [self removeConstraints:_constraints];
    }
    [_constraints removeAllObjects];
    [super setNeedsUpdateConstraints];
}

- (void)updateConstraints
{
    if([self isCustomContentView]){
        return [super updateConstraints];
    }
    
    if (_constraints.count>0) {
        [super updateConstraints];
        return;
    }
    if(_titleLabel.text&&_titleLabel.text.length>0){
        [_constraints addObject:[NSLayoutConstraint constraintWithItem:_titleLabel
                                                             attribute:NSLayoutAttributeLeft
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeLeft
                                                            multiplier:1
                                                              constant:self.contentInsets.left]];
        [_constraints addObject:[NSLayoutConstraint constraintWithItem:_titleLabel
                                                             attribute:NSLayoutAttributeRight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeRight
                                                            multiplier:1
                                                              constant:-self.contentInsets.right]];
        [_constraints addObject:[NSLayoutConstraint constraintWithItem:_titleLabel
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1
                                                              constant:self.contentInsets.top]];
        
        if(_messageLabel.text.length>0){
            [_constraints addObject:[NSLayoutConstraint constraintWithItem:_titleLabel
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_messageLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1
                                                                  constant:-kTitleMessageSpace]];
        }
        else{
            [_constraints addObject:[NSLayoutConstraint constraintWithItem:_titleLabel
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1
                                                                  constant:-self.contentInsets.bottom]];
        }
    }
    
    if(_messageLabel.text&&_messageLabel.text.length>0){
        if(_titleLabel.text&&_titleLabel.text.length>0){
            [_constraints addObject:[NSLayoutConstraint constraintWithItem:_messageLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_titleLabel
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1
                                                                  constant:kTitleMessageSpace]];
        }
        else{
            [_constraints addObject:[NSLayoutConstraint constraintWithItem:_messageLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1
                                                                  constant:self.contentInsets.top]];
        }
        [_constraints addObject:[NSLayoutConstraint constraintWithItem:_messageLabel
                                                             attribute:NSLayoutAttributeLeft
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeLeft
                                                            multiplier:1
                                                              constant:self.contentInsets.left]];
        [_constraints addObject:[NSLayoutConstraint constraintWithItem:_messageLabel
                                                             attribute:NSLayoutAttributeRight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeRight
                                                            multiplier:1
                                                              constant:-self.contentInsets.right]];
        
        CGFloat preferredTextWidth = kDefaultContainerWidth-self.contentInsets.left-self.contentInsets.right;
        CGSize aSize = SIZE_LABEL(_messageLabel.text, _messageLabel.font, CGSizeMake(preferredTextWidth, MAXFLOAT));
        if(aSize.height>kMaxMessageHeight){
            aSize.height = kMaxMessageHeight;
        }
        [_constraints addObject:[NSLayoutConstraint constraintWithItem:_messageLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:aSize.height]];
    }
    
    [self addConstraints:_constraints];
    [super updateConstraints];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@implementation XIBlurSupportedBackgroundView
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

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];

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

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@implementation XIAlertButtonItem

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self=[super initWithFrame:frame]){
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        [self addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        
        _backgroundView = [[XIBlurSupportedBackgroundView alloc] initWithFrame:self.bounds];
        _backgroundView.userInteractionEnabled = NO;
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:_backgroundView];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    if(highlighted){
        _backgroundView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:0.65];
        _backgroundView.blurView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    }
    else{
        _backgroundView.backgroundColor = [UIColor clearColor];
        _backgroundView.blurView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    }
}

- (void)touchUpInside:(UIButton *)btn
{
    if(_actionHanlder){
        _actionHanlder(self.alertView, self);
    }
}

@end


////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@implementation XIAlertViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.backgroundView.cropSize = self.alertView.intrinsicContentSize;
    [self.view insertSubview:self.alertView aboveSubview:self.backgroundView];
    
    self.alertView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.alertView setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self.alertView setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.alertView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.alertView
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1
                                                           constant:0]];
    
    [UIApplication sharedApplication].statusBarHidden = _rootViewControllerPrefersStatusBarHidden;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [UIApplication sharedApplication].statusBarHidden = _rootViewControllerPrefersStatusBarHidden;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [UIApplication sharedApplication].statusBarHidden = _rootViewControllerPrefersStatusBarHidden;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)prefersStatusBarHidden
{
    return _rootViewControllerPrefersStatusBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return _rootViewControllerPreferredStatusBarStyle;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@implementation XIAlertViewQueue
{
    NSMutableArray *_allAlerts;
}

+ (instancetype)sharedQueue{
    static XIAlertViewQueue *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[XIAlertViewQueue alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if(self=[super init]){
        _allAlerts = @[].mutableCopy;
    }
    return self;
}

- (BOOL)contains:(XIAlertView *)alertView
{
    return [_allAlerts containsObject:alertView];
}

- (XIAlertView *)dequeue
{
    if(_allAlerts.count>0){
        return [_allAlerts firstObject];
    }
    return nil;
}

- (void)enqueue:(XIAlertView *)alertView
{
    [_allAlerts addObject:alertView];
}

- (void)remove:(XIAlertView *)alertView
{
    if(_allAlerts.count>0){
        if([self contains:alertView]){
            [_allAlerts removeObject:alertView];
        }
    }
}

@end

@implementation XIAlertView (Creations)

+ (instancetype)alertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle
{
    XIAlertView *alert = [[XIAlertView alloc] initWithTitle:title message:message cancelButtonTitle:cancelButtonTitle];
    return alert;
}

+ (instancetype)alertWithCustomView:(UIView *)customView
              withPresentationStyle:(XICustomViewPresentationStyle)style
{
    XIAlertView *alert = [[XIAlertView alloc] initWithCustomView:customView withPresentationStyle:style];
    [alert show];
    return alert;
}

@end
