//
//  ViewController.h
//  Himachal
//
//  Created by Siraj Ravel on 7/31/15.
//  Copyright (c) 2015 Ellipse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AwesomeTextField.h"






@interface HMLoginViewController : UIViewController  <UITextFieldDelegate>


@property (nonatomic, strong) UITextField *testField;
@property (nonatomic, strong) AwesomeTextField *usernameTextField;
@property (nonatomic, strong) AwesomeTextField *passwordTextField;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UIButton *signupButton;


-(void) drawBackgroundGIF;



@end

