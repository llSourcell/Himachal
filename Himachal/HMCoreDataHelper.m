//
//  HMCoreDataHelper.m
//  Himachal
//
//  Created by Siraj Ravel on 8/2/15.
//  Copyright (c) 2015 Ellipse. All rights reserved.
//

#import "HMCoreDataHelper.h"
@import CoreData;

static NSString * const kHMDataBaseManagerFileName = @"DataModel";
static NSString * const kHMDataBaseManagerErrorDomain = @"HMErrorDomain";

typedef NS_ENUM(NSUInteger, OTSError) {
    OTSErrorModelURLNotCreated,
    OTSErrorManagedObjectModelNotCreated,
    OTSErrorPersistentStoreCoordinatorNotCreated
};

@interface HMCoreDataHelper()

@property (strong, nonatomic) NSManagedObjectContext *mainThreadManagedObjectContext;
@property (strong, nonatomic) NSManagedObjectContext *saveManagedObjectContext;
@property (strong, nonatomic) NSString *modelName;

@end

@implementation HMCoreDataHelper

- (instancetype)initWithModelName:(NSString *)modelName
{
    self = [super init];
    
    if (self) {
        _modelName = modelName;
    }
    
    return self;
}

- (instancetype)init
{
    return [self initWithModelName:kHMDataBaseManagerFileName];
}

- (void)setupCoreDataStackWithCompletionHandler:(HMDatabaseManagerCompletionHandler)handler
{
    if ([self saveManagedObjectContext]) return;
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:self.modelName withExtension:@"momd"];
    
    if (!modelURL) {
        NSError *customError = [self createErrorWithCode:OTSErrorManagedObjectModelNotCreated
                                                    desc:NSLocalizedString(@"The Model URL could not be found during setup.", nil)
                                              suggestion:NSLocalizedString(@"Do you want to try setting up the stack again?", nil)
                                                 options:@[@"Try Again", @"Cancel"]];
        
        handler(NO, customError);
        
        return;
    }
    
    NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    if (!mom) {
        NSError *customError = [self createErrorWithCode:OTSErrorManagedObjectModelNotCreated
                                                    desc:NSLocalizedString(@"The Managed Object Model could not be found during setup.", nil)
                                              suggestion:NSLocalizedString(@"Do you want to try setting up the stack again?", nil)
                                                 options:@[@"Try Again", @"Cancel"]];
        handler(NO, customError);
        return;
    }
    
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    
    if (!psc) {
        NSError *customError = [self createErrorWithCode:OTSErrorPersistentStoreCoordinatorNotCreated
                                                    desc:NSLocalizedString(@"The Persistent Store Coordinator could not be found during setup.", nil)
                                              suggestion:NSLocalizedString(@"Do you want to try setting up the stack again?", nil)
                                                 options:@[@"Try Again", @"Cancel"]];
        handler(NO, customError);
        return;
    }
    
    NSManagedObjectContext *saveMoc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [saveMoc setPersistentStoreCoordinator:psc];
    [self setSaveManagedObjectContext:saveMoc];
    
    NSManagedObjectContext *mainThreadMoc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [mainThreadMoc setParentContext:[self saveManagedObjectContext]];
    [self setMainThreadManagedObjectContext:mainThreadMoc];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSArray *directoryArray = [[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask];
        NSURL *storeURL = [directoryArray lastObject];
        
        NSError *error;
        
        if (![[NSFileManager defaultManager] createDirectoryAtURL:storeURL withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSError *customError = nil;
            
            if (error) {
                customError = [NSError errorWithDomain:kHMDataBaseManagerErrorDomain code:error.code userInfo:error.userInfo];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(NO, customError);
            });
        }
        
        storeURL = [[storeURL URLByAppendingPathComponent:self.modelName] URLByAppendingPathExtension:@"sqlite"];
        NSDictionary *options = @{ NSMigratePersistentStoresAutomaticallyOption: @YES, NSInferMappingModelAutomaticallyOption: @YES };
        NSPersistentStore *store = [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error];
        
        if (!store) {
            NSError *customError = nil;
            
            if (error) {
                customError = [NSError errorWithDomain:kHMDataBaseManagerErrorDomain code:error.code userInfo:error.userInfo];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(NO, customError);
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(YES, nil);
            });
        }
    });
}

- (NSError *)createErrorWithCode:(NSUInteger)code desc:(NSString *)description suggestion:(NSString *)suggestion options:(NSArray *)options
{
    NSParameterAssert(description);
    NSParameterAssert(suggestion);
    NSParameterAssert(options);
    
    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : description,
                                NSLocalizedRecoverySuggestionErrorKey : suggestion,
                                NSLocalizedRecoveryOptionsErrorKey : options };
    
    NSError *error = [NSError errorWithDomain:kHMDataBaseManagerErrorDomain code:code userInfo:userInfo];
    
    return error;
}

- (void)saveDataWithCompletionHandler:(HMDatabaseManagerCompletionHandler)handler
{
    if (![NSThread isMainThread]) { //Always start from the main thread
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self saveDataWithCompletionHandler:handler];
        });
        return;
    }
    
    //Don't work if you don't need to (you can talk to these without performBlock)
    if (![[self mainThreadManagedObjectContext] hasChanges] && ![[self saveManagedObjectContext] hasChanges]) {
        if (handler) handler(YES, nil);
        return;
    }
    
    if ([[self mainThreadManagedObjectContext] hasChanges]) {
        NSError *mainThreadSaveError = nil;
        if (![[self mainThreadManagedObjectContext] save:&mainThreadSaveError]) {
            if (handler) handler (NO, mainThreadSaveError);
            return; //fail early and often
        }
    }
    
    [[self saveManagedObjectContext] performBlock:^{ //private context must be on its on queue
        NSError *saveError = nil;
        if (![[self saveManagedObjectContext] save:&saveError]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (handler) handler(NO, saveError);
            });
            return;
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (handler) handler(YES, nil);
            });
        }
    }];
}

@end