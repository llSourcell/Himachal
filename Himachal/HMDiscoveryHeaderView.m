//
//  HMDiscoveryHeaderView.m
//  Himachal
//
//  Created by Siraj Ravel on 8/8/15.
//  Copyright (c) 2015 Ellipse. All rights reserved.
//

#import "HMDiscoveryHeaderView.h"
#import "HMDiscoveryViewController.h"
#import "AwesomeTextField.h"

@implementation HMDiscoveryHeaderView

#pragma mark UI drawing

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
    }
    return self;
}

- (void)layoutSubviews {
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    
    AwesomeTextField *myField= [[AwesomeTextField alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 50)];
myField.placeholder = @"Enter Search Term";
    myField.placeholderColor = [UIColor colorWithRed:0.62 green:0.42 blue:0.63 alpha:1.0];
    myField.underlineColor = [UIColor colorWithRed:0.62 green:0.42 blue:0.63 alpha:1.0];
    myField.returnKeyType = UIReturnKeyDone;

   // self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 50)];
   // self.searchBar.delegate = self;
    
    UIButton *userButton = [[UIButton alloc] initWithFrame:CGRectMake(0,50,screenWidth/2,50)];
    userButton.backgroundColor = [UIColor whiteColor];
    [userButton.layer setBorderColor:[[UIColor colorWithRed:0.62 green:0.42 blue:0.63 alpha:1.0] CGColor]];
    [userButton.layer setBorderWidth:1];
    [userButton setTitle:@"Users" forState:UIControlStateNormal];
    [userButton setTitleColor:[UIColor colorWithRed:0.62 green:0.42 blue:0.63 alpha:1.0] forState:UIControlStateNormal];
   
    [userButton addTarget:self action:@selector(showUsers) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *videoButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth/2,50,screenWidth/2,50)];
     [videoButton.layer setBorderColor:[[UIColor colorWithRed:0.62 green:0.42 blue:0.63 alpha:1.0] CGColor]];
    [videoButton.layer setBorderWidth:1];
    videoButton.backgroundColor = [UIColor whiteColor];
    [videoButton setTitle:@"Videos" forState:UIControlStateNormal];
    [videoButton setTitleColor:[UIColor colorWithRed:0.62 green:0.42 blue:0.63 alpha:1.0] forState:UIControlStateNormal];
    [videoButton addTarget:self action:@selector(showVideos) forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:myField];
    [self addSubview:userButton];
    [self addSubview:videoButton];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
 //   [self.delegate didPressSearchinHeaderSearchBar:searchBar];
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)aSearchBar {

}

- (IBAction)textFieldFinished:(id)sender
{
    [sender resignFirstResponder];
}

-(void) didPressSearchinHeader:(UITextField *)textField {
    
[self.delegate didPressSearchinHeader:textField];

    
}



-(void) showUsers {
    [self.delegate didPressUserButton];
    NSLog(@"show users");
}

-(void) showVideos {
    [self.delegate didPressVideoButton];
    NSLog(@"show videos");
}

@end
