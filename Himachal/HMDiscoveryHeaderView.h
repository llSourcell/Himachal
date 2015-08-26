//
//  HMDiscoveryHeaderView.h
//  Himachal
//
//  Created by Siraj Ravel on 8/8/15.
//  Copyright (c) 2015 Ellipse. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HMDiscoveryHeaderDelegate <NSObject>

- (void)didPressSearchinHeader:(UITextField *) textField;
- (void)didPressUserButton;
- (void)didPressVideoButton;
@end

@interface HMDiscoveryHeaderView : UIView <UISearchBarDelegate, HMDiscoveryHeaderDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) id <HMDiscoveryHeaderDelegate> delegate;

@end
