//
//  HMSignupViewController.h
//  Himachal
//
//  Created by Siraj Ravel on 7/31/15.
//  Copyright (c) 2015 Ellipse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AwesomeTextField.h"

@interface HMSignupViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) AwesomeTextField *emailTextField;
@property (nonatomic, strong) AwesomeTextField *usernameTextField;
@property (nonatomic, strong) AwesomeTextField *passwordTextField;
@property (nonatomic, strong) AwesomeTextField *passwordReentryTextField;
@property (nonatomic, strong) UIButton *signupButton;





@end
