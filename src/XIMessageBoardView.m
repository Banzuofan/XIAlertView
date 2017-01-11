//
//  XIMessageBoardView.m
//  XIAlertView
//
//  Created by YXLONG on 16/8/25.
//  Copyright © 2016年 yxlong. All rights reserved.
//

#import "XIMessageBoardView.h"


UIImage *imageFromColor(UIColor *color, CGSize size){
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#define TitleColor [UIColor colorWithRed:0 green:115.0/255.0 blue:146.0/255.0 alpha:1]
#define ButtonBgColor TitleColor
#define ContentInsetX 15
#define ButtinTitle @"I See"

@implementation XIMessageBoardView
{
    UILabel *titleLabel;
    UILabel *detailLabel;
    UIButton *closeButton;
    UIView *lineView;
}
- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title message:(NSString *)message
{
    if(self=[super initWithFrame:frame]){
        self.backgroundColor = [UIColor whiteColor];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.text = title;
        titleLabel.textColor = TitleColor;
        titleLabel.font = [UIFont boldSystemFontOfSize:21.0];
        titleLabel.numberOfLines = 1;
        [self addSubview:titleLabel];
        [titleLabel setContentHuggingPriority:751 forAxis:0];
        [titleLabel setContentHuggingPriority:751 forAxis:1];
        
        detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        detailLabel.text = message;
        detailLabel.font = [UIFont systemFontOfSize:21.0];
        detailLabel.numberOfLines = 0;
        [self addSubview:detailLabel];
        [detailLabel setContentHuggingPriority:751 forAxis:0];
        [detailLabel setContentHuggingPriority:751 forAxis:1];
        
        closeButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [closeButton setTitle:ButtinTitle forState:UIControlStateNormal];
        [closeButton setBackgroundImage:imageFromColor(ButtonBgColor, CGSizeMake(5, 5)) forState:UIControlStateNormal];
        [self addSubview:closeButton];
        [closeButton addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
        closeButton.layer.cornerRadius = 5;
        closeButton.clipsToBounds = YES;
        
        lineView = [[UIView alloc] initWithFrame:CGRectZero];
        lineView.backgroundColor = ButtonBgColor;
        [self addSubview:lineView];
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
        closeButton.translatesAutoresizingMaskIntoConstraints = NO;
        lineView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self setupConstraints];
    }
    return self;
}

- (void)buttonAction
{
    if(_buttonActionHandler){
        _buttonActionHandler();
    }
}

- (void)setupConstraints{
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:titleLabel
                                                        attribute:NSLayoutAttributeTop
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeTop
                                                       multiplier:1
                                                         constant:20],
                           [NSLayoutConstraint constraintWithItem:titleLabel
                                                        attribute:NSLayoutAttributeLeft
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeLeft
                                                       multiplier:1
                                                         constant:ContentInsetX]]];
    
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:detailLabel
                                                        attribute:NSLayoutAttributeLeft
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeLeft
                                                       multiplier:1
                                                         constant:ContentInsetX],
                           [NSLayoutConstraint constraintWithItem:detailLabel
                                                        attribute:NSLayoutAttributeRight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeRight
                                                       multiplier:1
                                                         constant:-ContentInsetX],
                           [NSLayoutConstraint constraintWithItem:detailLabel
                                                        attribute:NSLayoutAttributeTop
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:titleLabel
                                                        attribute:NSLayoutAttributeBottom
                                                       multiplier:1
                                                         constant:40]]];
    
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:closeButton
                                                        attribute:NSLayoutAttributeLeft
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeLeft
                                                       multiplier:1
                                                         constant:ContentInsetX],
                           [NSLayoutConstraint constraintWithItem:closeButton
                                                        attribute:NSLayoutAttributeRight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeRight
                                                       multiplier:1
                                                         constant:-ContentInsetX],
                           [NSLayoutConstraint constraintWithItem:closeButton
                                                        attribute:NSLayoutAttributeBottom
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeBottom
                                                       multiplier:1
                                                         constant:-ContentInsetX],
                           [NSLayoutConstraint constraintWithItem:closeButton
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1
                                                         constant:44]]];
    
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:lineView
                                                        attribute:NSLayoutAttributeTop
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:titleLabel
                                                        attribute:NSLayoutAttributeBottom
                                                       multiplier:1
                                                         constant:15],
                           [NSLayoutConstraint constraintWithItem:lineView
                                                        attribute:NSLayoutAttributeLeft
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeLeft
                                                       multiplier:1
                                                         constant:ContentInsetX],
                           [NSLayoutConstraint constraintWithItem:lineView
                                                        attribute:NSLayoutAttributeRight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeRight
                                                       multiplier:1
                                                         constant:0],
                           [NSLayoutConstraint constraintWithItem:lineView
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1
                                                         constant:1/[UIScreen mainScreen].scale]]];
    
}

@end

