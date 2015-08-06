//
//  ViewController.h
//  Himachal
//
//  Created by Siraj Ravel on 7/31/15.
//  Copyright (c) 2015 Ellipse. All rights reserved.
//

#import <UIKit/UIKit.h>





@interface HMLoginViewController : UIViewController  <UITextFieldDelegate>


@property (nonatomic, strong) UITextField *testField;
@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UIButton *signupButton;



@end

