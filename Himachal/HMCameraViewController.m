//
//  CameraViewController.m
//  Himachal
//
//  Created by Siraj Ravel on 8/2/15.
//  Copyright (c) 2015 Ellipse. All rights reserved.
//

#import "HMCameraViewController.h"
#import "HMCoreDataHelper.h"
#import "HMParseAPIHelper.h"
#import <Parse/Parse.h>
#import "MBProgressHUD.h"


@import CoreData;


@interface HMCameraViewController ()

@property(nonatomic, strong) ALAssetsLibrary *assetLibrary;
@property(nonatomic, strong) __block NSDictionary *currentVideo;
@property (nonatomic, strong) NSURL *myURL;
@property (nonatomic, assign) BOOL isRecording;
@property (strong, nonatomic) HMCoreDataHelper *databaseManager;
@property (nonatomic, strong)NSString *caption;
@property (nonatomic, strong)NSString *videoPath;
@property (nonatomic, strong) UIButton *recordingButton;
@property (nonatomic, strong) UILabel *recLabel;
@property (nonatomic, strong) UIButton *recCircle;



@end

@implementation HMCameraViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    [self drawCameraView];
    
}

-(void) viewWillAppear:(BOOL)animated {
    [self _resetCapture];
    [[PBJVision sharedInstance] startPreview];
}

-(void) viewWillDisappear:(BOOL)animated {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark UI elements

-(void) drawCameraView {
    // preview and AV layer
    self.previewView = [[UIView alloc] initWithFrame:CGRectZero];
    self.previewView.backgroundColor = [UIColor blackColor];
    CGRect previewFrame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    self.previewView.frame = previewFrame;
    self.previewLayer = [[PBJVision sharedInstance] previewLayer];
    self.previewLayer.frame = self.previewView.bounds;
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.previewView.layer addSublayer:self.previewLayer];
    
    self.isRecording = FALSE;
    self.assetLibrary = [[ALAssetsLibrary alloc] init];
    
    self.focusTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleFocusTapGesterRecognizer:)];
    self.focusTapGestureRecognizer.delegate = self;
    self.focusTapGestureRecognizer.numberOfTapsRequired = 1;
    self.focusTapGestureRecognizer.enabled = YES;
    [self.previewView addGestureRecognizer:self.focusTapGestureRecognizer];
    
}

-(void) drawSnapButton {
    UIButton * snapButton = [UIButton buttonWithType:UIButtonTypeCustom];
    snapButton.frame = CGRectMake(125, 400, 70.0f, 70.0f);
    snapButton.clipsToBounds = YES;
    snapButton.layer.cornerRadius = 70.0f / 2.0f;
    snapButton.layer.borderColor =  [UIColor colorWithRed:0.62 green:0.42 blue:0.63 alpha:1.0].CGColor;
    snapButton.layer.borderWidth = 2.0f;
    snapButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    snapButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
    snapButton.layer.shouldRasterize = YES;
    [snapButton addTarget:self action:@selector(snapButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:snapButton];
    
    [self.view bringSubviewToFront:snapButton];
    
    
}

-(void) drawFlipButton {
    UIButton *flipButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    flipButton.frame = CGRectMake(260, 10, 50.0f, 50.0f);
    [flipButton addTarget:self action:@selector(_handleFlipButton:) forControlEvents:UIControlEventTouchUpInside];
    // flipButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    [self.view addSubview:flipButton];
    [flipButton setBackgroundImage:[UIImage imageNamed:@"flipIcon.png"]
                          forState:UIControlStateNormal];
    [self.view bringSubviewToFront:flipButton];
    
}

-(void) drawRecordingButton {
    self.recordingButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.recordingButton.frame = CGRectMake(260, 10, 50.0f, 50.0f);
    [self.recordingButton addTarget:self action:@selector(_handleFlipButton:) forControlEvents:UIControlEventTouchUpInside];
    // flipButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    [self.recordingButton setBackgroundImage:[UIImage imageNamed:@"recording.png"]
                                    forState:UIControlStateNormal];
}


-(void) drawButtons {
    [self drawSnapButton];
    [self drawFlipButton];
    [self drawRecordingButton];
}

-(void) drawRecordingUI {
    [self.view addSubview:self.recordingButton];
    [self.view bringSubviewToFront:self.recordingButton];
    self.recLabel = [[UILabel alloc] initWithFrame:CGRectMake(275, 40, 50.0f, 50.0f)];
    self.recLabel.text = @"REC";
    self.recLabel.font = [UIFont fontWithName:@"Thonburi" size:16];
    self.recLabel.textColor = [UIColor redColor];
    [self.view addSubview:self.recLabel];
    [self.view bringSubviewToFront:self.recLabel];
    self.recCircle = [UIButton buttonWithType:UIButtonTypeCustom];
    self.recCircle.frame = CGRectMake(260, 60, 10.0f, 10.0f);
    self.recCircle.clipsToBounds = YES;
    self.recCircle.layer.cornerRadius = 10.0f / 2.0f;
    self.recCircle.backgroundColor = [UIColor redColor];
    self.recCircle.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.recCircle.layer.shouldRasterize = YES;
    [self.recCircle addTarget:self action:@selector(snapButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.recCircle];
    [self.view bringSubviewToFront:self.recCircle];
    [self flashOn:self.recCircle];
}


- (void)flashOff:(UIView *)v
{
    [UIView animateWithDuration:.50 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^ {
        v.alpha = .01;  //don't animate alpha to 0, otherwise you won't be able to interact with it
    } completion:^(BOOL finished) {
        [self flashOn:v];
    }];
}

- (void)flashOn:(UIView *)v
{
    [UIView animateWithDuration:.50 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^ {
        v.alpha = 1;
    } completion:^(BOOL finished) {
        [self flashOff:v];
    }];
}



#pragma mark tap delegate

- (void)_handleFocusTapGesterRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint tapPoint = [gestureRecognizer locationInView:self.previewView];
    
    // auto focus is occuring, display focus view
    CGPoint point = tapPoint;
    self.recCircle = [UIButton buttonWithType:UIButtonTypeCustom];
    self.recCircle.frame = CGRectMake(tapPoint.x, tapPoint.y, 60.0f, 60.0f);
    self.recCircle.clipsToBounds = YES;
    self.recCircle.layer.cornerRadius = 60.0f / 2.0f;
    self.recCircle.backgroundColor = [UIColor colorWithRed:0.00 green:0.40 blue:0.20 alpha:0.5];
    self.recCircle.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.recCircle.layer.shouldRasterize = YES;
    [self.recCircle addTarget:self action:@selector(snapButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.recCircle];
    [self.view bringSubviewToFront:self.recCircle];
    [self.recCircle setNeedsDisplay];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.5];
    [self.recCircle setAlpha:0.0];
    [UIView commitAnimations];
    
  
    
    CGRect focusFrame = self.focusView.frame;
#if defined(__LP64__) && __LP64__
    focusFrame.origin.x = rint(point.x - (focusFrame.size.width * 0.5));
    focusFrame.origin.y = rint(point.y - (focusFrame.size.height * 0.5));
#else
    focusFrame.origin.x = rintf(point.x - (focusFrame.size.width * 0.5f));
    focusFrame.origin.y = rintf(point.y - (focusFrame.size.height * 0.5f));
#endif
    [self.focusView setFrame:focusFrame];
    
    [self.previewView addSubview:self.focusView];
    [self.view bringSubviewToFront:self.focusView];
    [self.focusView startAnimation];
    
    CGPoint adjustPoint = [PBJVisionUtilities convertToPointOfInterestFromViewCoordinates:tapPoint inFrame:self.previewView.frame];
    [[PBJVision sharedInstance] focusExposeAndAdjustWhiteBalanceAtAdjustedPoint:adjustPoint];
}



#pragma mark camera methods

- (void)_resetCapture
{
    
    PBJVision *vision = [PBJVision sharedInstance];
    vision.delegate = self;
    vision.cameraMode = PBJCameraModeVideo;
    vision.cameraOrientation = PBJCameraOrientationPortrait;
    vision.focusMode = PBJFocusModeContinuousAutoFocus;
    vision.outputFormat = PBJOutputFormatSquare;
    vision.videoRenderingEnabled = YES;
    vision.additionalCompressionProperties = @{AVVideoProfileLevelKey : AVVideoProfileLevelH264Baseline30};
}


- (void)_handleFlipButton:(UIButton *)button
{
    PBJVision *vision = [PBJVision sharedInstance];
    vision.cameraDevice = vision.cameraDevice == PBJCameraDeviceBack ? PBJCameraDeviceFront : PBJCameraDeviceBack;
}

-(void) snapButtonPressed {
    
    if(self.isRecording == FALSE) {
        [[PBJVision sharedInstance] startVideoCapture];
        self.isRecording = TRUE;
        NSLog(@"started");
        [self drawRecordingUI];

    } else {
        [[PBJVision sharedInstance] endVideoCapture];
        [self.recordingButton removeFromSuperview];
        [self.recLabel removeFromSuperview];
        [self flashOff:self.recCircle];
        [self.recCircle removeFromSuperview];
        NSLog(@"Stopped");
    }
}


-(void) showVideoPreview {
    
    // allocate controller
    self.videoPlayerController = [[PBJVideoPlayerController alloc] init];
    
    self.videoPlayerController.delegate = self;
    self.videoPlayerController.view.frame = self.view.bounds;
    
    // setup media
    self.videoPlayerController.videoPath = [self.myURL absoluteString];
    
    //show video player
    [self presentViewController:self.videoPlayerController animated:YES completion:^{
    }];
    
}

- (void) displayContentController: (UIViewController*) content;
{
    UIView *lol = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 400)];
    [self addChildViewController:content];
    content.view.frame = CGRectMake(0, 0, 300, 300);
    [self.view addSubview:lol];
    [content didMoveToParentViewController:self];
}

#pragma mark - PBJVisionDelegate

- (void)visionSessionWillStart:(PBJVision *)vision
{
}

- (void)visionSessionDidStart:(PBJVision *)vision
{
    if (![self.previewView superview]) {
        [self.view addSubview:self.previewView];
        [self.view bringSubviewToFront:self.gestureView];
    }
    [self drawButtons];
    
}

- (void)vision:(PBJVision *)vision capturedVideo:(NSDictionary *)videoDict error:(NSError *)error
{
    self.isRecording = NO;
    
    if (error && [error.domain isEqual:PBJVisionErrorDomain] && error.code == PBJVisionErrorCancelled) {
        NSLog(@"recording session cancelled");
        return;
    } else if (error) {
        NSLog(@"encounted an error in video capture (%@)", error);
        return;
    }
    
    self.currentVideo = videoDict;
    
    self.videoPath = [self.currentVideo objectForKey:PBJVisionVideoPathKey];
    self.myURL = [NSURL URLWithString:self.videoPath];

    
    [self showVideoPreview];
   

 

}



- (void)visionSessionDidStop:(PBJVision *)vision
{
    [self.previewView removeFromSuperview];
}

// preview

- (void)visionSessionDidStartPreview:(PBJVision *)vision
{
    NSLog(@"Camera preview did start");
    
}

- (void)visionSessionDidStopPreview:(PBJVision *)vision
{
    NSLog(@"Camera preview did stop");
}

// device

- (void)visionCameraDeviceWillChange:(PBJVision *)vision
{
    NSLog(@"Camera device will change");
}

- (void)visionCameraDeviceDidChange:(PBJVision *)vision
{
    NSLog(@"Camera device did change");
}

// mode

- (void)visionCameraModeWillChange:(PBJVision *)vision
{
    NSLog(@"Camera mode will change");
}

- (void)visionCameraModeDidChange:(PBJVision *)vision
{
    NSLog(@"Camera mode did change");
}

// format

- (void)visionOutputFormatWillChange:(PBJVision *)vision
{
    NSLog(@"Output format will change");
}

- (void)visionOutputFormatDidChange:(PBJVision *)vision
{
    NSLog(@"Output format did change");
}

- (void)vision:(PBJVision *)vision didChangeCleanAperture:(CGRect)cleanAperture
{
}


- (void)visionWillStartFocus:(PBJVision *)vision
{
}

- (void)visionDidStopFocus:(PBJVision *)vision
{
    
}

- (void)visionWillChangeExposure:(PBJVision *)vision
{
}

- (void)visionDidChangeExposure:(PBJVision *)vision
{
    
}


- (void)visionDidChangeFlashMode:(PBJVision *)vision
{
}

#pragma mark - PBJVideoPlayerControllerDelegate

- (void)videoPlayerReady:(PBJVideoPlayerController *)videoPlayer
{
    //NSLog(@"Max duration of the video: %f", videoPlayer.maxDuration);
}

- (void)videoPlayerPlaybackStateDidChange:(PBJVideoPlayerController *)videoPlayer
{
}

- (void)videoPlayerBufferringStateDidChange:(PBJVideoPlayerController *)videoPlayer
{
}

- (void)videoPlayerPlaybackWillStartFromBeginning:(PBJVideoPlayerController *)videoPlayer
{
}

- (void)videoPlayerPlaybackDidEnd:(PBJVideoPlayerController *)videoPlayer
{
    
}






@end
