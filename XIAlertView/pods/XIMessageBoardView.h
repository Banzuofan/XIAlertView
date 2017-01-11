//
//  XIMessageBoardView.h
//  XIAlertView
//
//  Created by YXLONG on 16/8/25.
//  Copyright © 2016年 yxlong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XIMessageBoardView : UIView
@property(nonatomic, copy) dispatch_block_t buttonActionHandler;
- (instancetype)initWithFrame:(CGRect)frame
                        title:(NSString *)title
                      message:(NSString *)message;
@end
