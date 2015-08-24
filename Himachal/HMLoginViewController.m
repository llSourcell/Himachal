//
//  ViewController.m
//  Himachal
//
//  Created by Siraj Ravel on 7/31/15.
//  Copyright (c) 2015 Ellipse. All rights reserved.
//

#import "HMLoginViewController.h"
#import "HMSignupViewController.h"
#import "HMParseAPIHelper.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "RKSwipeBetweenViewControllers.h"
#import "HMCoreDataHelper.h"
#import "HMCameraViewController.h"
#import "HMProfileViewController.h"
#import "HMDiscoveryViewController.h"
#import "HMActivityViewController.h"
#import "HMUser.h"



@import CoreData;



@interface HMLoginViewController ()
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (strong, nonatomic) HMCoreDataHelper *databaseManager;



@end

@implementation UINavigationBar (custom)

- (UINavigationItem *)popNavigationItemAnimated:(BOOL)animated
{
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.navController popViewControllerAnimated:NO];
    return nil;
}


@end

@implementation HMLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //setup
   [self setupCoreData:^(BOOL succeeded) {
       if(succeeded) {
           BOOL isAuthenticated = [self checkifUserHasLoggedinPreviously];
           if(!isAuthenticated) {
               [self drawLoginUI];
           }
       }
   }];
   



}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark draw UI Elements

-(void) drawLoginUI {
    [self setTextFieldProperties:self.usernameTextField placeholderText:@"enter username" initWithFrame:CGRectMake(30, 200, 250, 40) andTag:(NSInteger) 1 security:FALSE];
    [self setTextFieldProperties:self.passwordTextField placeholderText:@"enter password" initWithFrame:CGRectMake(30, 250, 250, 40) andTag:(NSInteger) 2 security:TRUE];
    //NSLog(@"self. %@", self.usernameTextField);
    [self drawLoginButton];
    [self drawSignUpButton];
    [self detectTapOutsideTextFields];
    [self setAutoLayoutConstraints];
  
  
    
}




-(void) setTextFieldProperties: (UITextField *) myField placeholderText :(NSString*) text  initWithFrame: (CGRect) rect andTag:(NSInteger) tag security:(BOOL) isSecure {
    myField= [[UITextField alloc] initWithFrame:rect];
    //NSLog(@"my field %@", myField);
    myField.borderStyle = UITextBorderStyleRoundedRect;
    myField.autocapitalizationType = UITextAutocapitalizationTypeNone;
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
    myField.translatesAutoresizingMaskIntoConstraints = NO;
    [myField addTarget:myField
                action:@selector(resignFirstResponder)
      forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.view addSubview:myField ];
}
-(void) drawLoginButton {
    
    self.loginButton = [[UIButton alloc] initWithFrame:CGRectMake(110, 350, 150, 50)];
    self.loginButton.backgroundColor = [UIColor blackColor];
    [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
    [self.view addSubview:self.loginButton];
    
    //create event listener
    [self.loginButton addTarget:self action:@selector(loginTapped) forControlEvents:UIControlEventTouchUpInside];
    
    
}


-(void) drawSignUpButton {
    
    self.signupButton = [[UIButton alloc] initWithFrame:CGRectMake(110, 450, 150, 50)];
    self.signupButton.backgroundColor = [UIColor blackColor];
    [self.signupButton setTitle:@"Signup" forState:UIControlStateNormal];
    [self.view addSubview:self.signupButton];
    
    //create event listener
    [self.signupButton addTarget:self action:@selector(signupTapped) forControlEvents:UIControlEventTouchUpInside];
    
}


-(void) setAutoLayoutConstraints {
    
    //get subviews
//    NSArray *array = [self.view subviews];
//    
//    UITextField * userField = [array objectAtIndex:0];
    //Center the username text field
//   NSArray *constraints = [NSLayoutConstraint
//                            constraintsWithVisualFormat:@"V:|-offsetTop-[userField]"
//                            options:0
//                            metrics:@{@"offsetTop": @100}
//                            views:NSDictionaryOfVariableBindings(userField)];
//    
//    UIView *spacer1 = [UIView new];
//    spacer1.translatesAutoresizingMaskIntoConstraints = NO;
//    [self.view addSubview:spacer1];
//    
//    UIView *spacer2 = [UIView new];
//    spacer2.translatesAutoresizingMaskIntoConstraints = NO;
//    [self.view addSubview:spacer2];
//    
//    [self.view addConstraints:[NSLayoutConstraint
//                               constraintsWithVisualFormat:@"H:|[spacer1][userField][spacer2(==spacer1)]|"
//                               options:0
//                               metrics:nil
//                               views:NSDictionaryOfVariableBindings(userField, spacer1, spacer2)]];
//    
//    
//    
    //space between user and password textfield
//    UITextField *passField = [array objectAtIndex:0];
//    NSArray *constraints2 =
//    [NSLayoutConstraint constraintsWithVisualFormat:@"[userField]-[passField]"
//                                            options:0 metrics:nil views:NSDictionaryOfVariableBindings( userField, passField)];
//    
//    [self.view addConstraints:constraints2];
//    
    
}

#pragma mark UI State Detection

-(void) detectTapOutsideTextFields {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissLoginKeyboard)];
    
    [self.view addGestureRecognizer:tap];
}

-(void) dismissLoginKeyboard {
    [self.view endEditing:YES];
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    [self animateTextField:textField up:NO];

    if(textField.tag == 1) {
        self.username = textField.text;
    } else if(textField.tag == 2) {
        self.password = textField.text;
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

-(void) loginTapped {
    
    [self dismissLoginKeyboard];
    
    
    NSLog(@"selff %@", self.usernameTextField);

    if([self.username length] < 5) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter a username at least 5 characters long" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    else if([self.password length] < 5) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter a password at least 5 characters long" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    } else {
        [self login];
    
    }
    
}

-(void) login {
    
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[HMParseAPIHelper sharedInstance] loginUser:self.username passwordString:self.password completion:^(PFUser *user, NSError *error) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if(!error) {
            [self showNavController];
            NSLog(@"The user data is %@", user);
            [self saveUserDatawithUsername:user.username andPassword:self.password andEmail:user.email];
        }
        else {
            NSLog(@"The error is %@", [error localizedDescription]);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }];
    
    
}

#pragma mark core data

-(void) setupCoreData: (void (^)(BOOL suceeded))completion {
    //setup core data stack
    
    [self setDatabaseManager:[[HMCoreDataHelper alloc] init]];
    [[self databaseManager] setupCoreDataStackWithCompletionHandler:^(BOOL suceeded, NSError *error) {
        if (suceeded) {
            NSLog(@"Core Data passed");
            [self.view setNeedsDisplay];
            completion(suceeded);
        } else {
            NSLog(@"Core Data stack setup failed.");
            completion(nil);
        }
    }];
}


- (void) saveUserDatawithUsername:(NSString*) username andPassword:(NSString*) password andEmail:(NSString*) email {
    NSManagedObject *userObject = [[NSManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:@"HMUser" inManagedObjectContext:[[self databaseManager] mainThreadManagedObjectContext]] insertIntoManagedObjectContext:[[self databaseManager] mainThreadManagedObjectContext]];
    [userObject setValue:username forKey:@"username"];
    [userObject setValue:email forKey:@"email"];
    [userObject setValue:password forKey:@"password"];

    [[self databaseManager] saveDataWithCompletionHandler:^(BOOL suceeded, NSError *error) {
        if (!suceeded) {
            NSLog(@"Core Data save failed.");
        }
        else {
            NSLog(@"SUCCESS");
        }
    }];
}

-(BOOL) checkifUserHasLoggedinPreviously {

    NSManagedObjectContext *moc = [[self databaseManager] mainThreadManagedObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"HMUser"];
    NSError *error = nil;
    NSArray *fetchedObjects = [moc executeFetchRequest:fetchRequest error:&error];
    if(fetchedObjects == nil || [fetchedObjects count] == 0) {
        return FALSE;
    } else {
        
        HMUser *cachedUser = [fetchedObjects objectAtIndex:0];
        self.username = cachedUser.username;
        self.password = cachedUser.password;
        [self login];
        return TRUE;
    }
}


#pragma mark view segues

-(void) showNavController {
    
    
    UIPageViewController *pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    RKSwipeBetweenViewControllers *navigationController = [[RKSwipeBetweenViewControllers alloc]initWithRootViewController:pageController];
    navigationController.buttonText = @[@"Camera", @"Profile", @"Discovery", @"Activity"];
    
    //%%% DEMO CONTROLLERS
    HMCameraViewController *demo = [[HMCameraViewController alloc]init];
    HMProfileViewController *demo2 = [[HMProfileViewController alloc]init];
    HMDiscoveryViewController *demo3 = [[HMDiscoveryViewController alloc]init];
    HMActivityViewController *demo4 = [[HMActivityViewController alloc]init];
    demo.view.backgroundColor = [UIColor clearColor];
    demo2.view.backgroundColor = [UIColor whiteColor];
    demo4.view.backgroundColor = [UIColor orangeColor];
    [navigationController.viewControllerArray addObjectsFromArray:@[demo,demo2,demo3,demo4]];
    
    [self presentViewController:navigationController animated:NO completion:^{
        NSLog(@"Pushed");
    }];

}


-(void) signupTapped {
    
    NSLog(@"signup tapped ");
    HMSignupViewController* signupView = [[HMSignupViewController alloc] init];
    [self.navigationController pushViewController:signupView animated:NO];

    
}





@end
