//
//  ViewController.m
//  XIAlertView
//
//  Created by YXLONG on 16/7/21.
//  Copyright © 2016年 yxlong. All rights reserved.


#import "ViewController.h"
#import "XIAlertView.h"
#import "XIMessageBoardView.h"

#import "XIActionSheetHeaderView.h"
#import "XIActionSheet.h"
#import "XIActionSheetButtonItem.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>
@property(nonatomic, strong) UITableView *contentTable;
@end

@implementation ViewController
{
    NSArray *items;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    items = @[@"Simple Alerts",
              @"Multiline text Alerts",
              @"Custom Style Alert",
              @"System Alert",
              @"System ActionSheet",
              @"Custom ActionSheet",
              @"ActionSheet-Buttons-6",
              @"ActionSheet-Buttons-more than 6",
              @"ActionSheet-Text-short",
              @"ActionSheet-Text-long"];
    
    _contentTable = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _contentTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    _contentTable.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    _contentTable.delegate = self;
    _contentTable.dataSource = self;
    [self.view addSubview:_contentTable];
    _contentTable.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    _contentTable.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table_bg"]];
    
    UISwitch *bgSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(15, 20, 0, 0)];
    bgSwitch.on = YES;
    [self.view addSubview:bgSwitch];
    [bgSwitch addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    
    
//    XIActionSheetHeaderView *header = [[XIActionSheetHeaderView alloc] initWithFrame:CGRectZero];
//    
//    header.backgroundColor = [UIColor redColor];
//    
//    [header setTitle:@"Swift is a new programming language for iOS, OS X, and watchOS app development."];
//    [header setMessage:@"Swift is a new programming language for iOS, OS X, and watchOS app development.Swift is a new programming language for iOS, OS X, and watchOS app development.Swift is a new programming language for iOS, OS X, and watchOS app development.Swift is a new programming language for iOS, OS X, and watchOS app development.Swift is a new programming language for iOS, OS X, and watchOS app development."];
//    [self.view addSubview:header];
//    
//    header.translatesAutoresizingMaskIntoConstraints = NO;
//    
//    [header setContentHuggingPriority:751 forAxis:1];
//    [header setContentHuggingPriority:751 forAxis:0];
//    
//    header.preferredMaxLayoutWidth = 300;
//    
//    NSArray *arr =  @[[NSLayoutConstraint constraintWithItem:header
//                                                   attribute:NSLayoutAttributeCenterX
//                                                   relatedBy:NSLayoutRelationEqual
//                                                      toItem:self.view
//                                                   attribute:NSLayoutAttributeCenterX
//                                                  multiplier:1
//                                                    constant:0],
//                      [NSLayoutConstraint constraintWithItem:header
//                                                   attribute:NSLayoutAttributeTop
//                                                   relatedBy:NSLayoutRelationEqual
//                                                      toItem:self.view
//                                                   attribute:NSLayoutAttributeTop
//                                                  multiplier:1
//                                                    constant:40]];
//    [self.view addConstraints:arr];
    
    
                      
}

- (void)valueChanged:(UISwitch *)switchC
{
    if(switchC.isOn){
        _contentTable.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table_bg"]];
    }
    else{
        _contentTable.backgroundView = nil;
    }
}

#pragma mark-- dataSource and delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"ReusedCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor = [UIColor colorWithWhite:1 alpha:0.35];
    }
    cell.textLabel.text = items[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    __block NSString *message = @"Swift is a new programming language for iOS, OS X, and watchOS app development.";
    NSString *title = @"XIAlertView";
    if(indexPath.row==0){
        
        XIAlertView *alertView = [[XIAlertView alloc] initWithTitle:title
                                                            message:message
                                                  cancelButtonTitle:@"Cancel"];
        [alertView addDefaultStyleButtonWithTitle:@"Confirm" handler:^(XIAlertView *alertView, XIAlertButtonItem *buttonItem) {
            [alertView dismiss];
        }];
        [alertView show];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            XIAlertView *alertView = [[XIAlertView alloc] initWithTitle:message
                                                                message:nil
                                                      cancelButtonTitle:@"Cancel"];
            [alertView addDefaultStyleButtonWithTitle:@"Confirm" handler:^(XIAlertView *alertView, XIAlertButtonItem *buttonItem) {
                [alertView dismiss];
            }];
            [alertView show];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                XIAlertView *alertView = [[XIAlertView alloc] initWithTitle:nil
                                                                    message:message
                                                          cancelButtonTitle:@"OK"];
                [alertView show];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    XIAlertView *alertView = [[XIAlertView alloc] initWithTitle:title
                                                                        message:message
                                                              cancelButtonTitle:@"Cancel"];
                    [alertView addDefaultStyleButtonWithTitle:@"Default" handler:^(XIAlertView *alertView, XIAlertButtonItem *buttonItem) {
                        [alertView dismiss];
                    }];
                    [alertView addButtonWithTitle:@"Destructive" style:XIAlertActionStyleDestructive handler:^(XIAlertView *alertView, XIAlertButtonItem *buttonItem) {
                        [alertView dismiss];
                    }];
                    [alertView show];
                });
            });
        });
    }
    else if(indexPath.row==1){
        
        message = @"You can define Swift enumerations to store associated values of any given type, and the value types can be different for each case of the enumeration if needed. Enumerations similar to these are known as discriminated unions, tagged unions, or variants in other programming languages.Like C, Swift uses variables to store and refer to values by an identifying name. Swift also makes extensive use of variables whose values cannot be changed.Swift also makes extensive use of variables whose values cannot be changed.Swift also makes extensive use of variables whose values cannot be changed.";
        XIAlertView *alertView = [[XIAlertView alloc] initWithTitle:title
                                                            message:message
                                                  cancelButtonTitle:@"Cancel"];
        [alertView addDefaultStyleButtonWithTitle:@"Confirm" handler:^(XIAlertView *alertView, XIAlertButtonItem *buttonItem) {
            [alertView dismiss];
        }];
        [alertView show];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            XIAlertView *alertView = [[XIAlertView alloc] initWithTitle:title
                                                                message:message
                                                      cancelButtonTitle:@"Cancel"];
            [alertView addDefaultStyleButtonWithTitle:@"Confirm" handler:^(XIAlertView *alertView, XIAlertButtonItem *buttonItem) {
                [alertView dismiss];
            }];
            [alertView addButtonWithTitle:@"I don't agree" style:XIAlertActionStyleDestructive handler:^(XIAlertView *alertView, XIAlertButtonItem *buttonItem) {
                [alertView dismiss];
            }];
            [alertView show];
        });
    }
    else if(indexPath.row==2){
        XIMessageBoardView *customView = [[XIMessageBoardView alloc] initWithFrame:CGRectMake(0, 0, 280, 400) title:@"CustomView" message:@"You can define Swift enumerations to store associated values of any given type, and the value types can be different for each case of the enumeration if needed. "];
        XIAlertView *alert = [XIAlertView alertWithCustomView:customView withPresentationStyle:Default];
        __weak XIAlertView *weak_alert = alert;
        [customView setButtonActionHandler:^{
            [weak_alert dismiss];
        }];
    }
    else if(indexPath.row==3){
        __block UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"UIAlertView"
                                                                message:message
                                                               delegate:nil
                                                      cancelButtonTitle:@"Confirm"
                                                      otherButtonTitles:@"Cancel", nil];
        [alert show];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            alert = [[UIAlertView alloc] initWithTitle:nil
                                               message:message
                                              delegate:nil
                                     cancelButtonTitle:@"Confirm"
                                     otherButtonTitles:@"Cancel", nil];
            [alert show];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                alert = [[UIAlertView alloc] initWithTitle:message
                                                   message:nil
                                                  delegate:nil
                                         cancelButtonTitle:@"Confirm"
                                         otherButtonTitles:@"Cancel", nil];
                [alert show];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    message = @"You can define Swift enumerations to store associated values of any given type, and the value types can be different for each case of the enumeration if needed. Enumerations similar to these are known as discriminated unions, tagged unions, or variants in other programming languages.";
                    alert = [[UIAlertView alloc] initWithTitle:message
                                                       message:nil
                                                      delegate:nil
                                             cancelButtonTitle:@"Confirm"
                                             otherButtonTitles:@"Cancel", @"Destructive", nil];
                    [alert show];
                });
            });
        });
    }
    else if(indexPath.row==4){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Swift is a new programming language"
                                                                       message:@"You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values"
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"UIAlertActionStyleDestructive" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        
        for(int i=0;i<10;i++){
            [alert addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"button%@",@(i)]  style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[XIAlertView alertWithTitle:[NSString stringWithFormat:@"button%@",@(i)] message:nil cancelButtonTitle:@"OK"] show];
            }]];
        }
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else if(indexPath.row==5){
        
        XIActionSheet *actionSheet = [[XIActionSheet alloc] initWithTitle:@"Swift is a new programming language"
                                                                  message:@"You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values"
                                                        cancelButtonTitle:@"Cancel"];
        [actionSheet addButtonWithTitle:@"StyleDestructive" style:XIActionSheetButtonStyleDestructive handler:^(XIActionSheet *actionSheet, XIActionSheetButtonItem *buttonItem) {
            
        }];
        for(int i=0;i<10;i++){
            [actionSheet addDefaultStyleButtonWithTitle:[NSString stringWithFormat:@"button%@",@(i)] handler:^(XIActionSheet *actionSheet, XIActionSheetButtonItem *buttonItem) {
                [[XIAlertView alertWithTitle:[buttonItem titleForState:UIControlStateNormal] message:nil cancelButtonTitle:@"OK"] show];
            }];
        }
        [actionSheet show];
    }
    else if(indexPath.row==6){
        
        XIActionSheet *actionSheet = [[XIActionSheet alloc] initWithTitle:@"Swift is a new programming language"
                                                                  message:@""
                                                        cancelButtonTitle:@"Cancel"];
        for(int i=0;i<6;i++){
            [actionSheet addDefaultStyleButtonWithTitle:[NSString stringWithFormat:@"button%@",@(i)] handler:^(XIActionSheet *actionSheet, XIActionSheetButtonItem *buttonItem) {
                [[XIAlertView alertWithTitle:[buttonItem titleForState:UIControlStateNormal] message:nil cancelButtonTitle:@"OK"] show];
            }];
        }
        [actionSheet show];
    }
    else if(indexPath.row==7){
        
        XIActionSheet *actionSheet = [[XIActionSheet alloc] initWithTitle:@"Swift is a new programming language"
                                                                  message:@"You can define Swift enumerations to store associated values"
                                                        cancelButtonTitle:@"Cancel"];
        for(int i=0;i<12;i++){
            [actionSheet addDefaultStyleButtonWithTitle:[NSString stringWithFormat:@"button%@",@(i)] handler:^(XIActionSheet *actionSheet, XIActionSheetButtonItem *buttonItem) {
                [[XIAlertView alertWithTitle:[buttonItem titleForState:UIControlStateNormal] message:nil cancelButtonTitle:@"OK"] show];
            }];
        }
        [actionSheet show];
    }
    else if(indexPath.row==8){
        
        XIActionSheet *actionSheet = [[XIActionSheet alloc] initWithTitle:@"Swift is a new programming language"
                                                                  message:@"You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values"
                                                        cancelButtonTitle:@"Cancel"];
        [actionSheet show];
    }
    else if(indexPath.row==9){
        
        XIActionSheet *actionSheet = [[XIActionSheet alloc] initWithTitle:@"Swift is a new programming language"
                                                                  message:@"You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values.You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values.You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values.You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values.You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values,You can define Swift enumerations to store associated values"
                                                        cancelButtonTitle:@"Cancel"];
        [actionSheet show];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
