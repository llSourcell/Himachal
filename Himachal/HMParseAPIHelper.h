//
//  HMParseAPIHelper.h
//  Himachal
//
//  Created by Siraj Ravel on 8/1/15.
//  Copyright (c) 2015 Ellipse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>


@interface HMParseAPIHelper : NSObject

+ (HMParseAPIHelper *)sharedInstance;


//Authentication

-(void) loginUser:(NSString *) usernameString passwordString:(NSString *) passwordString completion:(void (^)(PFUser *user, NSError *error)) completion;

-(void) registerUser:(NSString*) usernameString  passwordString :(NSString *) passwordString  emailString:(NSString *) emailString completion:(void (^)(BOOL finished, NSError *error))completion;


//Videos
-(void) uploadVideoAsync:(NSString *) videoPath withCaption:(NSString *) caption completion:(void (^)(BOOL succeeded, NSError *error)) completion;

-(void) getVideos:(void (^)(NSArray * objects, NSError *error)) completion;


//Get user profile pic
-(void) getUserProfilePic:(void (^)(UIImage *profilePic, NSError *error)) completion;


-(void) setUserProfilePic:(UIImage *) chosenImage;









@end

