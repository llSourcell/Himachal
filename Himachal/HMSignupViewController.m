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
        self.view.backgroundColor = [UIColor whiteColor]; // or some other non-clear color
        
    }
    return self;
}



#pragma mark draw UI


-(void) drawUI {
    [self setTextFieldProperties:self.usernameTextField placeholderText:@"enter username" initWithFrame:CGRectMake(30, 200, 250, 40) andTag:(NSInteger) 1 security:FALSE];
    [self setTextFieldProperties:self.passwordTextField placeholderText:@"enter password" initWithFrame:CGRectMake(30, 250, 250, 40) andTag:(NSInteger) 2 security:TRUE];
    [self setTextFieldProperties:self.passwordReentryTextField placeholderText:@"enter password again" initWithFrame:CGRectMake(30, 300, 250, 40) andTag:(NSInteger) 3 security:TRUE];
    [self setTextFieldProperties:self.emailTextField placeholderText:@"enter email" initWithFrame:CGRectMake(30, 350, 250, 40) andTag:(NSInteger) 4 security:FALSE];
    [self drawSignupButton];
    [self detectTapOutsideTextFields];
    
}


-(void) setTextFieldProperties: (UITextField *) myField placeholderText :(NSString*) text  initWithFrame: (CGRect) rect andTag:(NSInteger) tag security:(BOOL) isSecure {
    myField= [[UITextField alloc] initWithFrame:rect];
    myField.borderStyle = UITextBorderStyleRoundedRect;
    [myField setReturnKeyType:UIReturnKeyDone];
    myField.font = [UIFont systemFontOfSize:15];
    myField.placeholder = text;
    myField.secureTextEntry = isSecure;
    myField.autocorrectionType = UITextAutocorrectionTypeNo;
    myField.keyboardType = UIKeyboardTypeDefault;
    myField.returnKeyType = UIReturnKeyDone;
    myField.clearButtonMode = UITextFieldViewModeWhileEditing;
    myField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    myField.tag = tag;
    myField.delegate = self;
    [myField addTarget:myField
                  action:@selector(resignFirstResponder)
        forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.view addSubview:myField ];
}

-(void) drawSignupButton {
    
    //[1] draw
    self.signupButton = [[UIButton alloc] initWithFrame:CGRectMake(110, 400, 150, 50)];
    self.signupButton.backgroundColor = [UIColor blackColor];
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please fill in all credentials" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    //Passwords equal to each other?
    else if(![self.password isEqualToString:self.passwordReentry]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The passwords do not match!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    //Is the email valid?
    else if(![self.email isValidEmail]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The email is not Valid!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    //Signup if checks passed
    else {
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];

        [[HMParseAPIHelper sharedInstance] registerUser:self.username passwordString:self.password emailString:self.email completion:^(BOOL finished, NSError *error) {
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if(!error) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"You've signed up" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }];
        
    }
 
    

    
}

@end
