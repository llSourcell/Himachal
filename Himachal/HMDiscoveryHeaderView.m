//
//  HMDiscoveryHeaderView.m
//  Himachal
//
//  Created by Siraj Ravel on 8/8/15.
//  Copyright (c) 2015 Ellipse. All rights reserved.
//

#import "HMDiscoveryHeaderView.h"
#import "HMDiscoveryViewController.h"

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

    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(20, 20, 250, 50)];
    self.searchBar.delegate = self;
    
    UIButton *userButton = [[UIButton alloc] initWithFrame:CGRectMake(20,70,125,50)];
    userButton.backgroundColor = [UIColor greenColor];
    userButton.titleLabel.text = @"usernames";
    userButton.titleLabel.textColor = [UIColor blackColor];
    [userButton addTarget:self action:@selector(showUsers) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *videoButton = [[UIButton alloc] initWithFrame:CGRectMake(145,70,125,50)];
    videoButton.backgroundColor = [UIColor blackColor];
    videoButton.titleLabel.text = @"videos";
    videoButton.titleLabel.textColor = [UIColor greenColor];
    [videoButton addTarget:self action:@selector(showVideos) forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:self.searchBar];
    [self addSubview:userButton];
    [self addSubview:videoButton];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.delegate didPressSearchinHeaderSearchBar:searchBar];
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)aSearchBar {

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
