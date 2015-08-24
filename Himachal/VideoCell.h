//
//  VideoCell.h
//  Himachal
//
//  Created by Siraj Ravel on 8/7/15.
//  Copyright (c) 2015 Ellipse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Video.h"

@class VideoCell;

@protocol VideoCellDelegate <NSObject>
- (void)VideoCell:(VideoCell *)cell userDidTapToPlayPause:(AVPlayer *)player;
@end


@interface VideoCell : UITableViewCell

@property (nonatomic, strong, readonly) AVPlayer *videoPlayer;
@property (nonatomic, weak) id<VideoCellDelegate>delegate;
@property (nonatomic, strong) UILabel *timestamp;
@property (nonatomic, strong) AVPlayerLayer *videoLayer;



- (void)setVideo:(Video *)video;
+ (CGFloat)heightForCell;
-(void) destroy;
-(void) addButtonToCell;

- (void)play;
- (void)pause;

@end