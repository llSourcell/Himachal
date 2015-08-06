//
//  HMSignupViewController.h
//  Himachal
//
//  Created by Siraj Ravel on 7/31/15.
//  Copyright (c) 2015 Ellipse. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HMSignupViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *emailTextField;
@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UITextField *passwordReentryTextField;
@property (nonatomic, strong) UIButton *signupButton;





@end
