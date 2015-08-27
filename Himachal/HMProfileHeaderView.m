//
//  HMProfileHeaderView.m
//  Himachal
//
//  Created by Siraj Ravel on 8/7/15.
//  Copyright (c) 2015 Ellipse. All rights reserved.
//

#import "HMProfileHeaderView.h"
#import <Parse/Parse.h>
#import "HMSizes.h"
#import "HMParseAPIHelper.h"


@implementation HMProfileHeaderView



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

-(void) drawProfilePic {
    self.profilePicButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.profilePicButton.frame = CGRectMake([[HMSizes sharedInstance] getScreenWidth]/2-25, 10, 50.0f, 50.0f);
    self.profilePicButton.clipsToBounds = YES;
    self.profilePicButton.layer.cornerRadius = 50.0f / 2.0f;
    self.profilePicButton.layer.borderColor =  [UIColor colorWithRed:0.62 green:0.42 blue:0.63 alpha:1.0].CGColor;
    self.profilePicButton.layer.borderWidth = 2.0f;
    self.profilePicButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    self.profilePicButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.profilePicButton.layer.shouldRasterize = YES;

    [[HMParseAPIHelper sharedInstance] getUserProfilePic:^(UIImage *profilePic, NSError *error) {
        if(!error) {
            [self.profilePicButton setImage:profilePic forState:UIControlStateNormal];
            [self setNeedsDisplay];
        } else {
            [self.profilePicButton setImage:[UIImage imageNamed:@"userIcon"] forState:UIControlStateNormal];
        }
        
    }];
    
    
    [self.profilePicButton addTarget:self action:@selector(profilePicButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.profilePicButton];
    
    
}

-(void) drawUsernameLabel {
    
    UILabel *label = [[UILabel alloc] init];
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"ArialRoundedMTBold" size:12.0f]};
    CGSize stringsize1 = [[PFUser currentUser].username sizeWithAttributes:attributes];
    [label setFrame:CGRectMake(0, 65, [[HMSizes sharedInstance] getScreenWidth],stringsize1.height)];
    [label setText:[PFUser currentUser].username];
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    
}


- (void)layoutSubviews {
 
    [self drawProfilePic];
    [self drawUsernameLabel];
}


#pragma mark event listeners

-(void) profilePicButtonPressed {
    [self.delegate profilePicButtonPressed];
   
}


@end
