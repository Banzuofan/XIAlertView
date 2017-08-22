//
//  UIView+XIAlertView.m
//  XIAlertView
//
//  Created by YXLONG on 2017/8/22.
//  Copyright © 2017年 yxlong. All rights reserved.
//

#import "UIView+XIAlertView.h"
#import "XIAlertView.h"

@implementation UIResponder (XIAlertView)
- (void)sendRCEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo
{
    [[self nextResponder] sendRCEventWithName:eventName userInfo:userInfo];
}
@end

@implementation UIView (XIAlertView)
- (void)dismissAlertView
{
    [self sendRCEventWithName:XIAlertViewRCEventDismiss userInfo:nil];
}
@end
