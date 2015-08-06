//
//  HMProfileViewController.m
//  Himachal
//
//  Created by Siraj Ravel on 8/5/15.
//  Copyright (c) 2015 Ellipse. All rights reserved.
//

#import "HMProfileViewController.h"
#import "HMCoreDataHelper.h"

@import CoreData;

@interface HMProfileViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) HMCoreDataHelper *databaseManager;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation HMProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self drawTableView];
    [self setTitle:@"Core Data Stack"];
    
    [self setDatabaseManager:[[HMCoreDataHelper alloc] init]];
    [[self databaseManager] setupCoreDataStackWithCompletionHandler:^(BOOL suceeded, NSError *error) {
        if (suceeded) {
            [[[self navigationItem] leftBarButtonItem] setEnabled:YES];
            [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
            [[self tableView] reloadData];
        } else {
            NSLog(@"Core Data stack setup failed.");
        }
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark draw UI

-(void) drawTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
}

#pragma mark Property Overrides

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController) return _fetchedResultsController;
    
    NSManagedObjectContext *moc = [[self databaseManager] mainThreadManagedObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"HMUser"];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"username" ascending:NO];
    [fetchRequest setSortDescriptors:@[ sort ]];
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:moc sectionNameKeyPath:nil cacheName:@"MainCache"];

    [self setFetchedResultsController:frc];
    [[self fetchedResultsController] setDelegate:self];
    
    NSError *error = nil;
    NSAssert([_fetchedResultsController performFetch:&error], @"Unresolved error %@\n%@", [error localizedDescription], [error userInfo]);
    return _fetchedResultsController;
}


#pragma mark - UITableViewDataSource Methods


//number of rows in the tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[[self fetchedResultsController] sections] count];
}


//number of columns in the tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sections = [[self fetchedResultsController] sections];
    id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

//values for each cell in the tableview
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    [[cell textLabel] setText:[object valueForKey:@"username"]];
    return cell;
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [[self tableView] beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:sectionIndex];
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [[self tableView] insertSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [[self tableView] deleteSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
            break;
        case NSFetchedResultsChangeUpdate:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    NSArray *newArray = nil;
    NSArray *oldArray = nil;
    
    if (newIndexPath) {
        newArray = [NSArray arrayWithObject:newIndexPath];
    }
    
    if (indexPath) {
        oldArray = [NSArray arrayWithObject:indexPath];
    }
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [[self tableView] insertRowsAtIndexPaths:newArray withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [[self tableView] deleteRowsAtIndexPaths:oldArray withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
        {
            UITableViewCell *cell = [[self tableView] cellForRowAtIndexPath:indexPath];
            NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
            [[cell textLabel] setText:[object valueForKey:@"dataItem"]];
            break;
        }
        case NSFetchedResultsChangeMove:
            [[self tableView] deleteRowsAtIndexPaths:oldArray withRowAnimation:UITableViewRowAnimationFade];
            [[self tableView] insertRowsAtIndexPaths:newArray withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [[self tableView] endUpdates];
}



@end
