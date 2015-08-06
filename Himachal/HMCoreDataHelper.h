//
//  HMCoreDataHelper.h
//  Himachal
//
//  Created by Siraj Ravel on 8/2/15.
//  Copyright (c) 2015 Ellipse. All rights reserved.
//

@import UIKit;

typedef void(^HMDatabaseManagerCompletionHandler)(BOOL suceeded, NSError *error);

@interface HMCoreDataHelper : NSObject

@property (strong, nonatomic, readonly) NSManagedObjectContext *mainThreadManagedObjectContext;

- (instancetype)initWithModelName:(NSString *)modelName NS_DESIGNATED_INITIALIZER;

- (void)setupCoreDataStackWithCompletionHandler:(HMDatabaseManagerCompletionHandler)handler;
- (void)saveDataWithCompletionHandler:(HMDatabaseManagerCompletionHandler)handler;

@end
