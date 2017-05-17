//
//  XIActionSheetHeaderView.m
//  XIAlertView
//
//  Created by YXLONG on 2017/5/16.
//  Copyright © 2017年 yxlong. All rights reserved.
//

#import "XIActionSheetHeaderView.h"

#define kLeftRightMargin 15
#define kTextColor [UIColor colorWithRed:0.561 green:0.561 blue:0.561 alpha:1.00]
#define kTextFontPointSize 12.5

static inline CGSize textBoundingSize(NSString *str, UIFont *font, CGSize constraints){
    if(!str) return CGSizeZero;
    if(!font) return CGSizeZero;
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineBreakMode:NSLineBreakByWordWrapping];
    
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    attributes[NSFontAttributeName] = font;
    
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    attributes[NSParagraphStyleAttributeName] = paragraphStyle;
    
    CGSize textSize = [str boundingRectWithSize:constraints
                                        options:NSStringDrawingUsesLineFragmentOrigin| NSStringDrawingUsesFontLeading
                                     attributes:attributes
                                        context:nil].size;
    
    return CGSizeMake(ceil(textSize.width), ceil(textSize.height));
}

@implementation XIActionSheetHeaderView
{
    UILabel *_titleLabel;
    UILabel *_messageLabel;
    
    NSString *_title;
    NSString *_message;
    
    NSMutableArray *_constraints;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self=[super initWithFrame:frame]){
        _constraints = [NSMutableArray array];
    }
    return self;
}

- (UILabel *)titleLabel
{
    if(!_titleLabel){
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = kTextColor;
        _titleLabel.numberOfLines = 0;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont boldSystemFontOfSize:kTextFontPointSize];
        _titleLabel.preferredMaxLayoutWidth = self.preferredTextAreaWidth;;
        [self addSubview:_titleLabel];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_titleLabel setContentHuggingPriority:751 forAxis:0];
        [_titleLabel setContentHuggingPriority:751 forAxis:1];
    }
    return _titleLabel;
}

- (UILabel *)messageLabel
{
    if(!_messageLabel){
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _messageLabel.textColor = kTextColor;
        _messageLabel.numberOfLines = 0;
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.font = [UIFont systemFontOfSize:kTextFontPointSize];
        _messageLabel.preferredMaxLayoutWidth = self.preferredTextAreaWidth;
        [self addSubview:_messageLabel];
        _messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_messageLabel setContentHuggingPriority:751 forAxis:0];
        [_messageLabel setContentHuggingPriority:751 forAxis:1];
    }
    return _messageLabel;
}

- (CGFloat)preferredTextAreaWidth
{
    return _preferredMaxLayoutWidth-kLeftRightMargin*2;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    
    self.titleLabel.text = _title;
    [self setNeedsUpdateConstraints];
}

- (void)setMessage:(NSString *)message
{
    _message = message;
    
    self.messageLabel.text = _message;
    [self setNeedsUpdateConstraints];
}

- (void)setPreferredMaxLayoutWidth:(CGFloat)preferredMaxLayoutWidth
{
    _preferredMaxLayoutWidth = preferredMaxLayoutWidth;
    
    self.titleLabel.preferredMaxLayoutWidth = self.preferredTextAreaWidth;
    self.messageLabel.preferredMaxLayoutWidth = self.preferredTextAreaWidth;
    
    [self invalidateIntrinsicContentSize];
    [self setNeedsUpdateConstraints];
}

- (CGSize)intrinsicContentSize
{
    CGSize constraints = CGSizeMake(self.preferredMaxLayoutWidth-kLeftRightMargin*2, HUGE);
    CGFloat contentHeight = 0;
    if(_title.length>0){
        contentHeight = 20;
        CGSize aSize = textBoundingSize(_title, _titleLabel.font, constraints);
        contentHeight += aSize.height;
    }
    
    if(_message.length>0){
        if(_title.length>0){
            contentHeight += 15;
        }
        else{
            contentHeight = 20;
        }
        CGSize bSize = textBoundingSize(_message, _messageLabel.font, constraints);
        contentHeight += bSize.height;
    }
    
    if(contentHeight>0){
        contentHeight += 20;
    }
    return CGSizeMake(self.preferredMaxLayoutWidth, contentHeight);
}

- (void)setNeedsUpdateConstraints
{
    [super setNeedsUpdateConstraints];
    
    if(_constraints.count>0){
        [NSLayoutConstraint deactivateConstraints:_constraints];
        [_constraints removeAllObjects];
    }
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    if(_title.length>0){
        [_constraints addObjectsFromArray:@[[NSLayoutConstraint constraintWithItem:_titleLabel
                                                                         attribute:NSLayoutAttributeCenterX
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self
                                                                         attribute:NSLayoutAttributeCenterX
                                                                        multiplier:1
                                                                          constant:0],
                                            [NSLayoutConstraint constraintWithItem:_titleLabel
                                                                         attribute:NSLayoutAttributeTop
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self
                                                                         attribute:NSLayoutAttributeTop
                                                                        multiplier:1
                                                                          constant:20]]];
        
        if(_message.length>0){
            [_constraints addObjectsFromArray:@[[NSLayoutConstraint constraintWithItem:_messageLabel
                                                                             attribute:NSLayoutAttributeCenterX
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self
                                                                             attribute:NSLayoutAttributeCenterX
                                                                            multiplier:1
                                                                              constant:0],
                                                [NSLayoutConstraint constraintWithItem:_messageLabel
                                                                             attribute:NSLayoutAttributeTop
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:_titleLabel
                                                                             attribute:NSLayoutAttributeBottom
                                                                            multiplier:1
                                                                              constant:15]]];
        }
    }
    else{
        if(_message.length>0){
            [_constraints addObjectsFromArray:@[[NSLayoutConstraint constraintWithItem:_messageLabel
                                                                             attribute:NSLayoutAttributeCenterX
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self
                                                                             attribute:NSLayoutAttributeCenterX
                                                                            multiplier:1
                                                                              constant:0],
                                                [NSLayoutConstraint constraintWithItem:_messageLabel
                                                                             attribute:NSLayoutAttributeTop
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self
                                                                             attribute:NSLayoutAttributeTop
                                                                            multiplier:1
                                                                              constant:20]]];
        }
    }
    
    if(_constraints.count>0){
        [NSLayoutConstraint activateConstraints:_constraints];
    }
}

@end
