//
//  HMSignupViewController.m
//  Himachal
//
//  Created by Siraj Ravel on 7/31/15.
//  Copyright (c) 2015 Ellipse. All rights reserved.
//

#import "HMSignupViewController.h"
#import "HMParseAPIHelper.h"
#import <Parse/Parse.h>
#import "NSString+emailValidation.h"
#import "MBProgressHUD.h"
#import "UIImageView+PlayGIF.h"
#import "RKDropdownAlert.h"
#import "HMSizes.h"



@interface HMSignupViewController ()

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *passwordReentry;
@property (nonatomic, strong) NSString *email;

@end

@implementation HMSignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self drawUI];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super init])) {
        
    }
    return self;
}


-(void) viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.62 green:0.42 blue:0.63 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self drawBackgroundGIF];

}


#pragma mark draw UI


-(void) drawUI {
    [self drawBackgroundGIF];
    [self drawInputTextfields];
    [self drawSignupButton];
    [self detectTapOutsideTextFields];
    
}

-(void) drawInputTextfields {
    [self setTextFieldProperties:self.usernameTextField placeholderText:@"enter username" initWithFrame:CGRectMake(30, 200, 250, 40) andTag:(NSInteger) 1 security:FALSE];
    [self setTextFieldProperties:self.passwordTextField placeholderText:@"enter password" initWithFrame:CGRectMake(30, 250, 250, 40) andTag:(NSInteger) 2 security:TRUE];
    [self setTextFieldProperties:self.passwordReentryTextField placeholderText:@"enter password again" initWithFrame:CGRectMake(30, 300, 250, 40) andTag:(NSInteger) 3 security:TRUE];
    [self setTextFieldProperties:self.emailTextField placeholderText:@"enter email" initWithFrame:CGRectMake(30, 350, 250, 40) andTag:(NSInteger) 4 security:FALSE];
}

-(void) drawBackgroundGIF {
    UIImageView *gifView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,[[HMSizes sharedInstance] getScreenWidth],[[HMSizes sharedInstance] getScreenHeight])];
    gifView.gifPath = [[NSBundle mainBundle] pathForResource:@"snowingmountain1.gif" ofType:nil];
    [self.view addSubview:gifView];
    [self.view sendSubviewToBack:gifView];
    [gifView startGIF];
}

-(void) setTextFieldProperties: (UITextField *) myField placeholderText :(NSString*) text  initWithFrame: (CGRect) rect andTag:(NSInteger) tag security:(BOOL) isSecure {
    myField= [[AwesomeTextField alloc] initWithFrame:rect];
    myField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [myField setReturnKeyType:UIReturnKeyDone];
    myField.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:17];
    myField.textColor = [UIColor whiteColor];
    myField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    myField.secureTextEntry = isSecure;
    myField.autocorrectionType = UITextAutocorrectionTypeNo;
    myField.keyboardType = UIKeyboardTypeDefault;
    myField.returnKeyType = UIReturnKeyDone;
    myField.clearButtonMode = UITextFieldViewModeWhileEditing;
    myField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    myField.tag = tag;
    myField.delegate = self;
    myField.translatesAutoresizingMaskIntoConstraints = NO;
    [myField addTarget:myField
                action:@selector(resignFirstResponder)
      forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.view addSubview:myField];
    [self.view bringSubviewToFront:myField];
}

-(void) drawSignupButton {
    //[1] draw
    self.signupButton = [[UIButton alloc] initWithFrame:CGRectMake(0, [[HMSizes sharedInstance] getScreenHeight]-50, [[HMSizes sharedInstance] getScreenWidth], 50)];
    self.signupButton.backgroundColor = [UIColor colorWithRed:0.62 green:0.42 blue:0.63 alpha:1.0];
    [self.signupButton setTitle:@"Signup" forState:UIControlStateNormal];
    [self.view addSubview:self.signupButton];
    
    //[2] create event listener
    [self.signupButton addTarget:self action:@selector(signup) forControlEvents:UIControlEventTouchUpInside];
    
    
}



#pragma mark UI state detection

-(void) detectTapOutsideTextFields {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(dismissSignupKeyboard)];
    
    [self.view addGestureRecognizer:tapGesture];
}

-(void) dismissSignupKeyboard {
    [self.view endEditing:YES];
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.passwordReentryTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
    
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    [self animateTextField:textField up:NO];

    if(textField.tag == 1) {
        self.username = textField.text;
    } else if(textField.tag == 2) {
        self.password = textField.text;
    } else if(textField.tag == 3) {
        self.passwordReentry = textField.text;
    }else if(textField.tag == 4) {
        self.email = textField.text;
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField:textField up:YES];
}

-(void)animateTextField:(UITextField*)textField up:(BOOL)up
{
    const int movementDistance = -130;
    const float movementDuration = 0.3f;
    
    int movement = (up ? movementDistance : -movementDistance);
    
    [UIView beginAnimations: @"animateTextField" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}


#pragma mark authentication

-(void) signup {
    
    [self dismissSignupKeyboard];

    
    //Empty values?
    if(self.username == nil  || self.password == nil || self.email == nil)
    {
   
         [RKDropdownAlert title:@"Error" message:@"Please fill in all credentials" backgroundColor:[UIColor colorWithRed:0.62 green:0.42 blue:0.63 alpha:1.0] textColor:[UIColor whiteColor] time:2];
    }
    //Passwords equal to each other?
    else if(![self.password isEqualToString:self.passwordReentry]) {
        [RKDropdownAlert title:@"Error" message:@"The passwords do not match!"  backgroundColor:[UIColor colorWithRed:0.62 green:0.42 blue:0.63 alpha:1.0] textColor:[UIColor whiteColor] time:2];

        
    }
    //Is the email valid?
    else if(![self.email isValidEmail]) {
        [RKDropdownAlert title:@"Error" message:@"The email is not Valid!"  backgroundColor:[UIColor colorWithRed:0.62 green:0.42 blue:0.63 alpha:1.0] textColor:[UIColor whiteColor] time:2];

    }
    //Signup if checks passed
    else {
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];

        [[HMParseAPIHelper sharedInstance] registerUser:self.username passwordString:self.password emailString:self.email completion:^(BOOL finished, NSError *error) {
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if(!error) {
                [RKDropdownAlert title:@"Success" message:@"You've signed up"  backgroundColor:[UIColor colorWithRed:0.62 green:0.42 blue:0.63 alpha:1.0] textColor:[UIColor whiteColor] time:2];
            }
            else {
                [RKDropdownAlert title:@"Error" message:[error localizedDescription]  backgroundColor:[UIColor colorWithRed:0.62 green:0.42 blue:0.63 alpha:1.0] textColor:[UIColor whiteColor] time:2];

            }
        }];
        
    }
}

@end
