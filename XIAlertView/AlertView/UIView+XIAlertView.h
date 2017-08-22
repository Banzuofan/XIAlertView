//
//  UIView+XIAlertView.h
//  XIAlertView
//
//  Created by YXLONG on 2017/8/22.
//  Copyright © 2017年 yxlong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIResponder (XIAlertView)
- (void)sendRCEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo;
@end

@class XIAlertView;
@interface UIView (XIAlertView)
- (void)dismissAlertView;
@end
