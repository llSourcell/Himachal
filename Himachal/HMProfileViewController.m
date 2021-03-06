//
//  HMProfileViewController2.m
//  Himachal
//
//  Created by Siraj Ravel on 8/7/15.
//  Copyright (c) 2015 Ellipse. All rights reserved.
//

#import "HMProfileViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "Video.h"
#import "VideoCell.h"
#import "HMProfileHeaderView.h"
#import "HMParseAPIHelper.h"


@interface HMProfileViewController () <VideoCellDelegate, HMProfileHeaderDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    
    
}
@property (nonatomic, strong, readwrite) AVPlayer *videoPlayer;
@property (nonatomic, strong) HMProfileHeaderView *headerView;


@end

@implementation HMProfileViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom the table
        
        // The className to query on
        self.parseClassName = @"video";
        
        // The key of the PFObject to display in the label of the default cell style
        self.textKey = @"text";
        //[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        
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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.headerView = [[HMProfileHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 100)];
    self.headerView.delegate = self;
    self.tableView.tableHeaderView = self.headerView;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark custom delegation 

-(void) profilePicButtonPressed {
    NSLog(@"pressed2");
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
    


}

#pragma mark image picker delegation

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self.headerView layoutSubviews];
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.headerView.profilePicButton.imageView.image = chosenImage;
    [[HMParseAPIHelper sharedInstance] setUserProfilePic:chosenImage];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
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
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query whereKey:@"createdBy" equalTo:[PFUser currentUser]];
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
   return [VideoCell heightForCell];
}


// Override to customize the look of a cell representing an object. The default is to display
// a UITableViewCellStyleDefault style cell with the label being the first key in the object.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"Cell";
    
    VideoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[VideoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    NSString *dateString = [NSDateFormatter localizedStringFromDate:object.updatedAt
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterFullStyle];

    cell.timestamp.text = dateString;

    PFFile *file = [object objectForKey:@"videoFile"];
    Video *vid = [Video videoWithStringURL:file.url];
    [cell setDelegate:self];
    [cell setVideo:vid];
    [cell play];
    
    return cell;
}


#pragma mark - Table view delegate

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

#pragma mark video delegate methods 
- (void)VideoCell:(VideoCell *)cell userDidTapToPlayPause:(AVPlayer *)player {
    
}


@end
