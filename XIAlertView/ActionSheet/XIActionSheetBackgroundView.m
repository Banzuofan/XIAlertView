//
//  XIActionSheetBackgroundView.m
//  XIAlertView
//
//  Created by YXLONG on 2017/5/17.
//  Copyright © 2017年 yxlong. All rights reserved.
//

#import "XIActionSheetBackgroundView.h"

extern CGFloat kCornerRadius;

static inline void XICreateRoundedRectPath(CGContextRef context, CGRect rect, CGFloat arcRadius)
{
    CGFloat halfSmallestSide = (rect.size.width > rect.size.height ? rect.size.height : rect.size.width)/2.0;
    if(arcRadius > halfSmallestSide)
        arcRadius = halfSmallestSide;
    else if(arcRadius < 0.0)
        arcRadius = 0.0;
    
    CGContextBeginPath(context);
    
    // move to top-left segment
    CGContextMoveToPoint(context,
                         rect.origin.x + arcRadius,
                         rect.origin.y);
    
    // move to top-right and do an arc
    CGContextAddArcToPoint(context,
                           rect.origin.x + rect.size.width,
                           rect.origin.y,
                           rect.origin.x + rect.size.width,
                           rect.origin.y + arcRadius,
                           arcRadius);
    
    // move to bottom-right and do an arc
    CGContextAddArcToPoint(context,
                           rect.origin.x + rect.size.width,
                           rect.origin.y + rect.size.height,
                           rect.origin.x + (rect.size.width - arcRadius),
                           rect.origin.y + rect.size.height,
                           arcRadius);
    
    // move to bottom-left and do an arc
    CGContextAddArcToPoint(context,
                           rect.origin.x,
                           rect.origin.y + rect.size.height,
                           rect.origin.x,
                           rect.origin.y + (rect.size.height - arcRadius),
                           arcRadius);
    
    // move to top-left and do an arc
    CGContextAddArcToPoint(context,
                           rect.origin.x,
                           rect.origin.y,
                           rect.origin.x + arcRadius,
                           rect.origin.y,
                           arcRadius);
    
    CGContextClosePath(context);
}

@interface XIActionSheetBackgroundView ()
{
    UIColor *fillColor;
    UIColor *strokeColor;
    CGRect  _cropRect;
    UIEdgeInsets _contentInsets;
}
@property(nonatomic, assign) UIEdgeInsets contentInsets;
@end

@implementation XIActionSheetBackgroundView
@synthesize cropRect=_cropRect;
@synthesize fillColor;

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if(self=[super initWithCoder:aDecoder]){
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self=[super initWithFrame:frame])
    {
        [self commonInit];
    }
    return self;
}

- (void)setFillColor:(UIColor *)color
{
    fillColor = color;
    [self setNeedsDisplay];
}

- (void)commonInit
{
    self.backgroundColor = [UIColor clearColor];
    _contentInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    fillColor = [UIColor colorWithWhite:0 alpha:0.35];
    strokeColor = [UIColor colorWithWhite:0.6 alpha:1];
}

- (void)setCropRect:(CGRect)cropRect
{
    _cropRect = cropRect;
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    if(!CGRectEqualToRect(_cropRect, CGRectZero)){
        
        CGContextSaveGState(ctx);
        
        XICreateRoundedRectPath(ctx,_cropRect, kCornerRadius);
        CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:0 alpha:0.15].CGColor);
        CGContextFillPath(ctx);
        
        CGContextRestoreGState(ctx);
        
        XICreateRoundedRectPath(ctx,_cropRect, kCornerRadius);
        CGContextAddRect(ctx,CGContextGetClipBoundingBox(ctx));
        CGContextEOClip(ctx);
    }
    
    CGContextSetFillColorWithColor(ctx, fillColor.CGColor);
    CGContextFillRect(ctx, self.bounds);
}

@end
