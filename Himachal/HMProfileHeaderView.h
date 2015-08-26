//
//  HMProfileHeaderView.h
//  Himachal
//
//  Created by Siraj Ravel on 8/7/15.
//  Copyright (c) 2015 Ellipse. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HMProfileHeaderDelegate <NSObject>

- (void)profilePicButtonPressed;

@end

@interface HMProfileHeaderView : UIView


@property (nonatomic, strong) id <HMProfileHeaderDelegate> delegate;

@property (nonatomic, strong) UIButton *profilePicButton;

@end
