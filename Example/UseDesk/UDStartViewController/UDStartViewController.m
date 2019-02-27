////
////  UDStartViewController.m
////  Use_Desk_iOS_SDK_Example
////
////  Created by Maxim Melikhov on 08.02.2018.
////  Copyright © 2018 Maxim. All rights reserved.
////
//#import "UseDeskSDK.h"
//#import "UDStartViewController.h"
//#import "Settings.h"
//
//
//
//@implementation UDStartViewController
//
//- (void)viewDidLoad {
//   
//    [super viewDidLoad];
//    
//    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName:navBarTextColor}];
//    
//    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
//
//    self.title = @"UseDesk SDK";
//    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]
//                                                          initWithTarget:self action:@selector(handleSingleTap:)];
//    
//    singleTapGestureRecognizer.numberOfTapsRequired = 1;
//    [self.view addGestureRecognizer:singleTapGestureRecognizer];
//    
//}
//
//
//- (BOOL)textFieldShouldReturn:(UITextField *)textField
//{
//    [textField resignFirstResponder];
//    return YES;
//}
//
//
//-(void) handleSingleTap:(UITapGestureRecognizer *)sender
//{
//    [self.view endEditing:YES];
//}
//
//
//- (void)didReceiveMemoryWarning {
//    
//    [super didReceiveMemoryWarning];
//    
//}
//
//-(IBAction)startChatButton:(id)sender{
//    UseDeskSDK * usedesk = [[UseDeskSDK alloc] init];
//    [usedesk startWithCompanyID:companyIdTextField.text email:emailTextField.text url:urlTextField.text port:portTextField.text connectionStatus:^(BOOL success, NSString *error) {
//        
//    }];
//}
//
//
//
//@end
