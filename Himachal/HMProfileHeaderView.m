//
//  HMProfileHeaderView.m
//  Himachal
//
//  Created by Siraj Ravel on 8/7/15.
//  Copyright (c) 2015 Ellipse. All rights reserved.
//

#import "HMProfileHeaderView.h"
#import <Parse/Parse.h>


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


- (void)layoutSubviews {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
 
    
    // snap button to capture image
    self.profilePicButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.profilePicButton.frame = CGRectMake(screenWidth/2-25, 10, 50.0f, 50.0f);
    self.profilePicButton.clipsToBounds = YES;
    self.profilePicButton.layer.cornerRadius = 50.0f / 2.0f;
    self.profilePicButton.layer.borderColor =  [UIColor colorWithRed:0.62 green:0.42 blue:0.63 alpha:1.0].CGColor;
    self.profilePicButton.layer.borderWidth = 2.0f;
    self.profilePicButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    self.profilePicButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.profilePicButton.layer.shouldRasterize = YES;
    
    
    PFQuery *pfQuery = [PFUser query];
    PFUser *user = [PFUser currentUser];

    [pfQuery whereKey:@"username" equalTo:user.username];
    pfQuery.limit = 1;
    
    [pfQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        PFObject *obj = [objects objectAtIndex:0];
        PFFile * file = [obj objectForKey:@"profilePic"];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:data];
                  [self.profilePicButton setImage:image forState:UIControlStateNormal];
                [self setNeedsDisplay];
            } else {
                [self.profilePicButton setImage:[UIImage imageNamed:@"userIcon"] forState:UIControlStateNormal];
            }
        }];
        if(!file) {
            [self.profilePicButton setImage:[UIImage imageNamed:@"userIcon"] forState:UIControlStateNormal];
        }

      
    }];
    
    
 
    [self.profilePicButton addTarget:self action:@selector(profilePicButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.profilePicButton];
   
    

    UILabel *label = [[UILabel alloc] init];
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"ArialRoundedMTBold" size:12.0f]};
    CGSize stringsize1 = [user.username sizeWithAttributes:attributes];
    [label setFrame:CGRectMake(0, 65, screenWidth,stringsize1.height)];
    [label setText:user.username];
    label.textAlignment = NSTextAlignmentCenter;
    
    
    [self addSubview:label];
    
}

-(void) profilePicButtonPressed {
    NSLog(@"Pressed1");

    [self.delegate profilePicButtonPressed];
   
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
