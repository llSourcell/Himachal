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
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(75, 50, 200, 50)];
    //button.backgroundColor = [UIColor blackColor];
    PFUser *user = [PFUser currentUser];
    
    label.text = user.username;
    [self addSubview:label];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
