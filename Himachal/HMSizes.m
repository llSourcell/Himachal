//
//  HMSizes.m
//  Himachal
//
//  Created by Siraj Ravel on 8/27/15.
//  Copyright (c) 2015 Ellipse. All rights reserved.
//

#import "HMSizes.h"

@implementation HMSizes


+ (HMSizes *)sharedInstance {
    static HMSizes *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HMSizes alloc] init];
    });
    return instance;
}



-(CGFloat) getScreenWidth {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    return screenWidth;
}

-(CGFloat) getScreenHeight {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    
    return screenHeight;
}

@end
