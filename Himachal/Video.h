//
//  Video.h
//  Himachal
//
//  Created by Siraj Ravel on 8/7/15.
//  Copyright (c) 2015 Ellipse. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface Video : NSObject
+ (instancetype)videoWithURL:(NSURL *)url;
+ (instancetype)videoWithStringURL:(NSString *)url;
- (AVAsset *)video;
@end
