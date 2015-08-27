//
//  HMSizes.h
//  Himachal
//
//  Created by Siraj Ravel on 8/27/15.
//  Copyright (c) 2015 Ellipse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



@interface HMSizes : NSObject


+ (HMSizes *)sharedInstance;



- (CGFloat) getScreenWidth;

- (CGFloat) getScreenHeight;


@end
