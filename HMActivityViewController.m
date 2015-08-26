//
//  HMActivityViewController.m
//  
//
//  Created by Siraj Ravel on 8/23/15.
//
//

#import "HMActivityViewController.h"
#import "VideoCell.h"

@interface HMActivityViewController () <VideoCellDelegate>

@property (strong, nonatomic) NSMutableArray *videos;

@end

@implementation HMActivityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createTheProperQuery];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)getPages:(int)numUsersFollowed filling:(NSMutableArray *)objects userIds:(NSMutableArray *) usersFollowed completion:(void (^)(BOOL))completion {
    // degenerate case is an empty array which means we're done
    if (numUsersFollowed == 0) return completion(YES);
    
    // otherwise, do the first operation on the to do list, then do the remainder
    numUsersFollowed--;
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:[usersFollowed objectAtIndex:numUsersFollowed]];
    //query to get their User Object
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *response, NSError *error){
        PFUser *userFollowing = (PFUser *) response;
        PFQuery *videosByUser = [PFQuery queryWithClassName:@"video"];
        [videosByUser whereKey:@"createdBy" equalTo:userFollowing];
        //query each user object to get their videos
        [videosByUser findObjectsInBackgroundWithBlock:^(NSArray *response, NSError *error) {
            
            for(PFObject *obj in response) {
                [self.videos addObject:obj];
                //add to mutable array of pfobjects to load tableview
            }
            [self getPages:numUsersFollowed filling:objects userIds:usersFollowed completion:completion];
            
        }];
        
    }];
    
}




-(void) createTheProperQuery {
    
    self.videos = [[NSMutableArray alloc] init];
    //query the user class
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query whereKey:@"objectId" equalTo:[PFUser currentUser].objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *response, NSError *error) {
        
        //get current user
        PFUser *currentUser = [response objectAtIndex:0];
        //get users that I follow
        NSMutableArray *usersFollowed = [currentUser objectForKey:@"usersFollowed"];
        [self getPages:(int)[usersFollowed count] filling:self.videos userIds:usersFollowed completion:^(BOOL success) {
               NSLog(@"done with these videos %@" , self.videos);
            [self sortVideos];
            [self.tableView reloadData];
            // here, we can update our UI
            // collecting the results in a dictionary allows us to know
            // which result goes with which request
            
          
        }];
        
        
        
        
    }];
    
}

-(void) sortVideos {
    
    NSSortDescriptor *dateDescriptor = [NSSortDescriptor
                                        sortDescriptorWithKey:@"createdAt"
                                        ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:dateDescriptor];
    self.videos =  (NSMutableArray *)[self.videos sortedArrayUsingDescriptors:sortDescriptors];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.videos count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    VideoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[VideoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    PFFile *file = [[self.videos objectAtIndex:indexPath.row] objectForKey:@"videoFile"];
    Video *vid = [Video videoWithStringURL:file.url];
    [cell setDelegate:self];
    [cell setVideo:vid];
    [cell play];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return [VideoCell heightForCell];
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
