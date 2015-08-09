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


-(void) drawButtons {
    // snap button to capture image
    UIButton * snapButton = [UIButton buttonWithType:UIButtonTypeCustom];
    snapButton.frame = CGRectMake(100, 200, 70.0f, 70.0f);
    snapButton.clipsToBounds = YES;
    snapButton.layer.cornerRadius = 70.0f / 2.0f;
    snapButton.layer.borderColor = [UIColor whiteColor].CGColor;
    snapButton.layer.borderWidth = 2.0f;
    snapButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    snapButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
    snapButton.layer.shouldRasterize = YES;
    [snapButton addTarget:self action:@selector(snapButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:snapButton];
    
    [self.view bringSubviewToFront:snapButton];
    
    
    
    UIButton *flipButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    flipButton.frame = CGRectMake(100, 400, 70.0f, 70.0f);
    [flipButton addTarget:self action:@selector(_handleFlipButton:) forControlEvents:UIControlEventTouchUpInside];
    flipButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    [self.view addSubview:flipButton];
    
    [self.view bringSubviewToFront:flipButton];
    
    
    UIButton *videoPreviewButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    videoPreviewButton.frame = CGRectMake(100, 300, 70.0f, 70.0f);
    [videoPreviewButton addTarget:self action:@selector(showVideoPreview) forControlEvents:UIControlEventTouchUpInside];
    videoPreviewButton.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
    [self.view addSubview:videoPreviewButton];
    
    [self.view bringSubviewToFront:videoPreviewButton];
}




#pragma mark tap delegate

- (void)_handleFocusTapGesterRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint tapPoint = [gestureRecognizer locationInView:self.previewView];
    
    // auto focus is occuring, display focus view
    CGPoint point = tapPoint;
    
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
    // specify a maximum duration with the following property
    // vision.maximumCaptureDuration = CMTimeMakeWithSeconds(5, 600); // ~ 5 seconds
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
    } else {
        [[PBJVision sharedInstance] endVideoCapture];
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
        NSLog(@"YO");
    }];
    
    //    [_videoPlayerController dismissViewControllerAnimated:YES completion:^{
    //        NSLog(@"YO2");
    //    }];
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

    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Caption" message:@"Input a caption" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [alert show];
 

 

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    self.caption =[[alertView textFieldAtIndex:0] text];
    [self uploadVideo];
    
    
}

-(void) uploadVideo {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[HMParseAPIHelper sharedInstance] uploadVideoAsync:self.videoPath withCaption:self.caption completion:^(BOOL succeeded, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if(succeeded) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"You've uploaded your video" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"You've uploaded your video" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            
        }
    }];
    
    
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
