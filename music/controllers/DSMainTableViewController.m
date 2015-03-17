//
//  ViewController.m
//  music
//
//  Created by dima on 3/7/15.
//  Copyright (c) 2015 dima. All rights reserved.
//

#import "DSVersionsTableViewController.h"
#import "DSMainTableViewController.h"
#import "DSMainTableViewCell.h"


@interface DSMainTableViewController ()

@property (strong, nonatomic) PFRelation* relation;

@end

@implementation DSMainTableViewController

- (id)initWithCoder:(NSCoder *)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self) {
        // Custom the table
        
        // The className to query on
        self.parseClassName = @"Music";
        
        // The key of the PFObject to display in the label of the default cell style
        self.textKey = @"name";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = NO;
        
        // The number of objects to show per page
        //self.objectsPerPage = 10;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshTable:)
                                                 name:@"refreshTable"
                                               object:nil];
}

- (void)refreshTable:(NSNotification *) notification
{
    // Reload the recipes
    [self loadObjects];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshTable" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (PFQuery *)queryForTable
{
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    /*    if ([self.objects count] == 0) {
     query.cachePolicy = kPFCachePolicyCacheThenNetwork;
     }*/
    
    //    [query orderByAscending:@"name"];
    
    return query;
}



// Override to customize the look of a cell representing an object. The default is to display
// a UITableViewCellStyleDefault style cell with the label being the first key in the object.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    static NSString *mainTableIdentifier = @"mainCell";
    
   DSMainTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:mainTableIdentifier];
    if (cell == nil) {
        cell = [[DSMainTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:mainTableIdentifier];
    }
    
    // Configure the cell
   // PFFile *thumbnail = [object objectForKey:@"imageFile"];
  //  PFImageView *thumbnailImageView = (PFImageView*)[cell viewWithTag:100];
   // thumbnailImageView.image = [UIImage imageNamed:@"placeholder.jpg"];
  //  thumbnailImageView.file = thumbnail;
  //  [thumbnailImageView loadInBackground];
    
   // UILabel *nameLabel = (UILabel*) [cell viewWithTag:101];
  //  nameLabel.text = [object objectForKey:@"name"];
  //
  ////  UILabel *prepTimeLabel = (UILabel*) [cell viewWithTag:102];
  ///  prepTimeLabel.text = [object objectForKey:@"prepTime"];
    cell.artistLabel.text = [object objectForKey:@"author"];
    cell.titleLabel.text = [object objectForKey:@"name"];
    cell.downloadBtn.tag = indexPath.row;
    [cell.downloadBtn addTarget:self action:@selector(downloadClicked:)
     forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove the row from data model
    PFObject *object = [self.objects objectAtIndex:indexPath.row];
    [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self refreshTable:nil];
    }];
}

- (void) objectsDidLoad:(NSError *)error
{
    [super objectsDidLoad:error];
    
    NSLog(@"error: %@", [error localizedDescription]);
}

#pragma marm - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   
    DSVersionsTableViewController* vc = [segue destinationViewController];
    vc.childrens = self.relation;
   
}

#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    PFObject *object = [self.objects objectAtIndex:indexPath.row];
    self.relation = [object relationForKey:@"versions"];
    return indexPath;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 60;
}

#pragma mark - Self Methods

- (void) downloadClicked:(id)sender {
    
    UIButton* btn = sender;
    PFObject *object = [self.objects objectAtIndex:btn.tag];
    PFFile *soundFile = object[@"mfile"];
    [soundFile getDataInBackgroundWithBlock:^(NSData *soundData, NSError *error) {
        if (!error) {
            NSLog(@"%@",soundFile.name);
        }
    }
    progressBlock:^(int percentDone) {
        
        NSLog(@"%d", percentDone);
        
    }];}

@end
