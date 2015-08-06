//
//  HMVideo.h
//  
//
//  Created by Siraj Ravel on 8/5/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface HMVideo : NSManagedObject

@property (nonatomic, retain) NSNumber * comment_count;
@property (nonatomic, retain) NSString * dataURL;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * downvote_count;
@property (nonatomic, retain) NSNumber * upvote_count;
@property (nonatomic, retain) NSData * user;
@property (nonatomic, retain) NSString * videoID;

@end
