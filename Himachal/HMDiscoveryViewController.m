//
//  HMDiscoveryViewController.m
//  Himachal
//
//  Created by Siraj Ravel on 8/8/15.
//  Copyright (c) 2015 Ellipse. All rights reserved.
//

#import "HMDiscoveryViewController.h"
#import "HMDiscoveryHeaderView.h"

@interface HMDiscoveryViewController () <HMDiscoveryHeaderDelegate>

@property (nonatomic, strong) HMDiscoveryHeaderView *headerView;


@end

@implementation HMDiscoveryViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom the table
        
        // The className to query on
        self.parseClassName = @"User";
        
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
    self.headerView = [[HMDiscoveryHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 100)];
    
    self.headerView.delegate = self;

    [self.tableView setTableHeaderView:self.headerView];
    //self.tableView.tableHeaderView = headerView;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





- (void) didPressSearchinHeaderSearchBar:(UISearchBar *)headerSearchBar {
    
    NSLog(@"here its %@", headerSearchBar.text);

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
   // PFQuery *query = [PFUser query];

    PFQuery *query = [PFQuery queryWithClassName:@"video"];
    [query whereKey:@"caption" equalTo:@"my"];
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
    return 50;
}


#pragma mark tableview
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    //if user
    NSString *username = [object objectForKey:@"test"];
    cell.textLabel.text = username ;

    //if video
    //NSDate *test = object.updatedAt;


    
    
  
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
