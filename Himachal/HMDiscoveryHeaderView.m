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
#import "HMSizes.h"

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

#pragma mark draw UI

-(void) drawSearchField {
    
    AwesomeTextField *myField= [[AwesomeTextField alloc] initWithFrame:CGRectMake(0, 0, [[HMSizes sharedInstance] getScreenWidth], 50)];
    myField.placeholder = @"Enter Search Term";
    myField.placeholderColor = [UIColor colorWithRed:0.62 green:0.42 blue:0.63 alpha:1.0];
    myField.underlineColor = [UIColor colorWithRed:0.62 green:0.42 blue:0.63 alpha:1.0];
    myField.returnKeyType = UIReturnKeyDone;
    [myField addTarget:myField
                action:@selector(resignFirstResponder)
      forControlEvents:UIControlEventEditingDidEndOnExit];
    myField.delegate = self;
    [self addSubview:myField];

    
}

-(void) drawUserButton {
    
    self.userButton = [[UIButton alloc] initWithFrame:CGRectMake(0,50,[[HMSizes sharedInstance] getScreenWidth]/2,50)];
    self.userButton.backgroundColor = [UIColor colorWithRed:0.62 green:0.42 blue:0.63 alpha:1.0];
    [self.userButton.layer setBorderColor:[[UIColor colorWithRed:0.62 green:0.42 blue:0.63 alpha:1.0] CGColor]];
    [self.userButton.layer setBorderWidth:1];
    [self.userButton setTitle:@"Users" forState:UIControlStateNormal];
    [self.userButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    
    [self.userButton addTarget:self action:@selector(showUsers:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.userButton];

}

-(void) drawVideoButton {
    
    self.videoButton = [[UIButton alloc] initWithFrame:CGRectMake([[HMSizes sharedInstance] getScreenWidth]/2,50,[[HMSizes sharedInstance] getScreenWidth]/2,50)];
    [self.videoButton.layer setBorderColor:[[UIColor colorWithRed:0.62 green:0.42 blue:0.63 alpha:1.0] CGColor]];
    [self.videoButton.layer setBorderWidth:1];
    self.videoButton.backgroundColor = [UIColor whiteColor];
    [self.videoButton setTitle:@"Videos" forState:UIControlStateNormal];
    [self.videoButton setTitleColor:[UIColor colorWithRed:0.62 green:0.42 blue:0.63 alpha:1.0] forState:UIControlStateNormal];
    [self.videoButton addTarget:self action:@selector(showVideos:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.videoButton];

}

- (void)layoutSubviews {
    [self drawSearchField];
    [self drawUserButton];
    [self drawVideoButton];
}


#pragma mark event listeners 

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self.delegate textFieldShouldReturn:textField];
    
    return NO;
 }

-(void) showUsers:(UIButton *) button {
    
    //if user button is white
    if(([button.backgroundColor isEqual: [UIColor whiteColor]])) {
        
        //turn user button purple
        button.backgroundColor = [UIColor colorWithRed:0.62 green:0.42 blue:0.63 alpha:1.0];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        //turn video button white
        self.videoButton.backgroundColor = [UIColor whiteColor];
        [self.videoButton setTitleColor:[UIColor colorWithRed:0.62 green:0.42 blue:0.63 alpha:1.0] forState:UIControlStateNormal];
    } 

}

-(void) showVideos:(UIButton *) button {
    
    //if video button is white
    if(([button.backgroundColor isEqual: [UIColor whiteColor]])) {
        
        //turn video button purple
        button.backgroundColor = [UIColor colorWithRed:0.62 green:0.42 blue:0.63 alpha:1.0];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        //turn user button white
        self.userButton.backgroundColor = [UIColor whiteColor];
        [self.userButton setTitleColor:[UIColor colorWithRed:0.62 green:0.42 blue:0.63 alpha:1.0] forState:UIControlStateNormal];
        
    }

}

@end
