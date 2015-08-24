//
//  CameraViewController.h
//  Himachal
//
//  Created by Siraj Ravel on 8/2/15.
//  Copyright (c) 2015 Ellipse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBJVision.h"
#import "PBJVisionUtilities.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "PBJFocusView.h"
#import "PBJVideoPlayerController.h"



//@import AVFoundation;

@interface HMCameraViewController : UIViewController <UIImagePickerControllerDelegate,PBJVisionDelegate, UIGestureRecognizerDelegate, PBJVideoPlayerControllerDelegate>

@property(nonatomic, strong) UIView *previewView;
@property(nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property(nonatomic, strong) PBJFocusView *focusView;
@property(nonatomic, strong) PBJVideoPlayerController *videoPlayerController;
@property(nonatomic, strong) UIView *gestureView;
@property(nonatomic, strong) UITapGestureRecognizer *focusTapGestureRecognizer;



@end
