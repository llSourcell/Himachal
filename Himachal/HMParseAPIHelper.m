//
//  HMParseAPIHelper.m
//  Himachal
//
//  Created by Siraj Ravel on 8/1/15.
//  Copyright (c) 2015 Ellipse. All rights reserved.
//

#import "HMParseAPIHelper.h"
#import <Parse/Parse.h>


@implementation HMParseAPIHelper

+ (HMParseAPIHelper *)sharedInstance {
    static HMParseAPIHelper *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HMParseAPIHelper alloc] init];
    });
    return instance;
}

-(void) loginUser:(NSString *) usernameString passwordString:(NSString *) passwordString completion:(void (^)(PFUser *user, NSError *error)) completion {
    
    [PFUser logInWithUsernameInBackground:usernameString password:passwordString
                                    block:^(PFUser *user, NSError *error) {
                                        if (user) {
                                                completion(user, nil);
                                        } else {
                                            completion(nil, error);
                                            // The login failed. Check error to see why.
                                        }
                                    }];
    
}


-(void) registerUser:(NSString*) usernameString  passwordString :(NSString *) passwordString  emailString:(NSString *) emailString completion:(void (^)(BOOL finished, NSError *error))completion  {
    
    PFUser *user = [PFUser user];
    user.username = usernameString;
    user.password = passwordString;
    user.email = emailString;
    
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // Hooray! Let them use the app now.
                completion(succeeded, nil);
        } else {
                completion(nil, error);
        }
    }];
    

}

-(void) uploadVideoAsync:(NSString *) videoPath withCaption:(NSString*) caption completion:(void (^)(BOOL succeeded, NSError *error)) completion {
    //save video to parse
    
    NSString *path = videoPath;
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:path];
    PFFile *videoFile = [PFFile fileWithName:@"video.mp4" data:data];
    PFObject *video= [PFObject objectWithClassName:@"video"];
    PFUser *user = [PFUser currentUser];
    [video setObject:user forKey:@"createdBy"];
    video[@"videoFile"] = videoFile;
    video[@"caption"] = caption;
    
    [video saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if(succeeded) {
            completion(TRUE, nil);
        }
        else {
            completion(FALSE,nil);
        }
    }];
}


-(void) getVideos:(void (^)(NSArray * objects, NSError *error)) completion  {
    
    PFQuery *query = [PFQuery queryWithClassName:@"video"];
    [query whereKey:@"createdBy" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            completion(objects, nil);
            NSLog(@"The objects are %@", objects);
        }
        else {
            completion (nil, error);
        }
    }];
}


@end
