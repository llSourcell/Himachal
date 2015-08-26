//
//  HMDiscoveryViewController.m
//  Himachal
//
//  Created by Siraj Ravel on 8/8/15.
//  Copyright (c) 2015 Ellipse. All rights reserved.
//

#import "HMDiscoveryViewController.h"
#import "HMDiscoveryHeaderView.h"
#import "Video.h"
#import "VideoCell.h"
#import <AVFoundation/AVFoundation.h>


@interface HMDiscoveryViewController () <HMDiscoveryHeaderDelegate, VideoCellDelegate>

@property (nonatomic, strong) HMDiscoveryHeaderView *headerView;
@property (nonatomic, strong) NSString *userOrVideoString;
@property (nonatomic, strong, readwrite) AVPlayer *videoPlayer;
@property (nonatomic, strong) NSMutableArray *myOwnCache;
@property (assign) int x;



@end

@implementation HMDiscoveryViewController

#pragma mark UI drawing

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom the table

        // The className to query on
        self.parseClassName = self.userOrVideoString;
        
        // The key of the PFObject to display in the label of the default cell style
        self.textKey = @"text";
        
        // The title for this table in the Navigation Controller.
        self.title = @"myvideos";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;

        // The number of objects to show per page
        self.objectsPerPage = 5;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.x = 0;
    self.myOwnCache = [[NSMutableArray alloc] init];
    self.headerView = [[HMDiscoveryHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 100)];
    self.headerView.delegate = self;
    [self.tableView setTableHeaderView:self.headerView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma header delegation 

-(void) didPressSearchinHeader:(UITextField *)textField {
    [textField resignFirstResponder];
    NSLog(@"FHUIFHS");
}
 

-(void) didPressUserButton {
    self.userOrVideoString = @"User";
    [self loadObjects];
}

-(void) didPressVideoButton {
    self.userOrVideoString = @"video";
    [self loadObjects];
}





#pragma mark - Parse

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    // This method is called every time objects are loaded from Parse via the PFQuery
}

- (void)objectsWillLoad {
    [super objectsWillLoad];
    
    // This method is called before a PFQuery is fired to get more objects
}


// Override to customize what kind of query to perform on the class. The default is to query for
// all objects ordered by createdAt descending.
- (PFQuery *)queryForTable {
    PFQuery *query;
    if([self.userOrVideoString isEqualToString:@"video"]) {
        query = [PFQuery queryWithClassName:self.userOrVideoString];
    } else if([self.userOrVideoString isEqualToString:@"User"]) {
         query = [PFUser query];
    } else {
        query = [PFQuery queryWithClassName:self.userOrVideoString];
    }
    //[query whereKey:@"caption" equalTo:@"my"];
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if ([self.objects count] == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query orderByDescending:@"updatedAt"];
    return query;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if([self.userOrVideoString isEqualToString:@"video"]) {
        return [VideoCell heightForCell];
    }
    else {
        return 50;
    }

}



#pragma mark tableview



- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView.contentOffset.y <= 10)
    {
        //scrollup
        
        [self.navigationController setNavigationBarHidden: NO animated:YES];
    }
    else if(scrollView.contentOffset.y >= 10)
    {
        //scrolldown
        [self.navigationController setNavigationBarHidden: YES animated:YES];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"Cell";
    static NSString *CellIdentifier2 = @"Cell2";
    
    

    
        if([self.userOrVideoString isEqualToString:@"video"]) {
            VideoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
            if (cell == nil) {
                cell = [[VideoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
//            NSString *dateString = [NSDateFormatter localizedStringFromDate:object.updatedAt
//                                                                  dateStyle:NSDateFormatterShortStyle
//                                                                  timeStyle:NSDateFormatterFullStyle];
//            
//            
            PFFile *file = [object objectForKey:@"videoFile"];
            Video *vid = [Video videoWithStringURL:file.url];
            [cell setDelegate:self];
            [cell setVideo:vid];
             [cell play];
            return cell;
        }
        else {
            
            VideoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
            if (cell == nil) {
                cell = [[VideoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
             //   [cell addButtonToCell];
            cell.textLabel.text = [object objectForKey:@"username"];
            return cell;
            
        }

}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //TODO wrap this and put it in the helper class pull from users followed array.
    PFQuery *innerQuery = [PFQuery queryWithClassName:@"_User"];
    [innerQuery whereKey:@"objectId" equalTo:[PFUser currentUser].objectId];
    [innerQuery findObjectsInBackgroundWithBlock:^(NSArray *response, NSError *error) {
        
        PFUser *currentUser = [response objectAtIndex:0];
        NSMutableArray *usersFollowed = [currentUser objectForKey:@"usersFollowed"];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        //if doesn't exist.
        if(![usersFollowed containsObject:cell.textLabel.text]) {
            [usersFollowed addObject:cell.textLabel.text];
            currentUser[@"usersFollowed"]  = usersFollowed;
            [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"YAY");
                } else {
                    NSLog(@"YAY2");

                }
            }];
            
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You've already followed this user" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
        }
        
        
        
       

    }];
    
    
    //TODO Follow functionality
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}



@end
