//
//  VideoCell.m
//  Himachal
//
//  Created by Siraj Ravel on 8/7/15.
//  Copyright (c) 2015 Ellipse. All rights reserved.
//


#import "VideoCell.h"

@interface VideoCell()
@property (nonatomic, strong) UIView *videoView;
@property (nonatomic, strong, readwrite) AVPlayer *videoPlayer;
@property (nonatomic, strong) AVPlayerLayer *videoLayer;
@property (nonatomic, strong) UIImageView *placeholder;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@end

@implementation VideoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    self.videoView = [[UIView alloc] init];
    [self.contentView addSubview:self.videoView];
    self.videoPlayer = [[AVPlayer alloc] init];
    self.timestamp = [[UILabel alloc] initWithFrame:CGRectMake(0,0,200,20)];
  ///  label.text = @"hello";
    [self.contentView addSubview:self.timestamp];
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.videoView setFrame:CGRectMake(10, 50, self.contentView.frame.size.width - 20, self.contentView.frame.size.width)];
    [self.videoLayer setFrame:self.videoView.bounds];
    [self.placeholder setFrame:self.videoView.bounds];
    [self.indicator setCenter:self.videoView.center];
}

- (void)setVideo:(Video *)video
{
    NSLog(@"%s : %@", __PRETTY_FUNCTION__, video);
    
    //[self generateImageFromAsset:video];
    //[self.videoView addSubview:self.placeholder];
    
    [self.videoPlayer replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithAsset:video.video]];
    [self.videoPlayer setActionAtItemEnd:AVPlayerActionAtItemEndNone];
    self.videoLayer = [AVPlayerLayer playerLayerWithPlayer:self.videoPlayer];
    [self.videoLayer setPlayer:self.videoPlayer];
    [self.videoLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
    [self.videoView.layer addSublayer:self.videoLayer];
    self.videoPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.videoPlayer currentItem]];
    
    // Here we add an KVO to the player to know when the video is ready to play
    // This is important if you want the user to see something while the video is being loaded
    [self.videoPlayer addObserver:self forKeyPath:@"status" options:0 context:nil];
    
    // Here we need to add the indicator to the video views layer
    // Then start animating
    // But if the video is already ready to play, then we dont add it
    // This case comes up when the video has been cached like we have done so
    // and the cell is being reused
    if ([self.videoPlayer status] != AVPlayerStatusReadyToPlay) {
        [self.videoView.layer addSublayer:[self.indicator layer]];
        [self.indicator startAnimating];
    }
    
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}

- (void)generateImageFromAsset:(AVAsset *)asset
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        CGFloat ratio = 0.0f;
        AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        CMTime duration = asset.duration;
        CGFloat durationInSeconds = duration.value / duration.timescale;
        CMTime time = CMTimeMakeWithSeconds(durationInSeconds * ratio, (int)duration.value);
        CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
        UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.placeholder = [[UIImageView alloc] initWithImage:thumbnail];
        });
    });
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    
    if (object == self.videoPlayer && [keyPath isEqualToString:@"status"]) {
        
        // If the video player has loaded the content
        // We stop animating the indicator, remove it from the layer
        // Then play the video
        if (self.videoPlayer.status == AVPlayerStatusReadyToPlay) {
            
            //[self.videoPlayer play];
            [self.placeholder setHidden:YES];
            [self.indicator stopAnimating];
            [self.indicator.layer removeFromSuperlayer];
            //playButton.enabled = YES;
            
        } else if (self.videoPlayer.status == AVPlayerStatusFailed) {
            
            // something went wrong. player.error should contain some information
            
        } else if (self.videoPlayer.status == AVPlayerStatusUnknown) {
            
            // dont know :(
            
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    /*
     * For us to detect touches on the video, we need to implement 'hitTest:'
     * which returns yes or no, depending on whether the layer was actually touched
     * If the player is currently playing, then we pause, else we play
     *
     * IMPORTANT: If we don't touch on the video layer, we call the super method
     * to allow for any other components (UIView's) to handle touches implemented
     */
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchPoint = [touch locationInView:touch.view];
    if ([self.videoLayer hitTest:touchPoint]) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(VideoCell:userDidTapToPlayPause:)]) {
            [self.delegate VideoCell:self userDidTapToPlayPause:self.videoPlayer];
        }
        
        if ([self.videoPlayer rate] == 1.0f) {
            [self pause];
        } else {
            [self play];
        }
    } else {
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)play
{
    [self.videoPlayer play];
}

- (void)pause
{
    [self.videoPlayer pause];
}

+ (CGFloat)heightForCell
{
    return [UIScreen mainScreen].bounds.size.width + 50;
}

- (UIActivityIndicatorView *)indicator
{
    if (!_indicator) {
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
    return _indicator;
}

@end
