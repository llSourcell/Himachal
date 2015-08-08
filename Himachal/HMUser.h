//
//  HMUser.h
//  
//
//  Created by Siraj Ravel on 8/6/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface HMUser : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * facebookID;
@property (nonatomic, retain) NSNumber * follower_count;
@property (nonatomic, retain) NSNumber * following_count;
@property (nonatomic, retain) NSData * profilePicture;
@property (nonatomic, retain) NSString * userID;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSNumber * videoCount;
@property (nonatomic, retain) NSString * password;

@end
