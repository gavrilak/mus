//
//  ViewController.m
//  music
//
//  Created by dima on 3/7/15.
//  Copyright (c) 2015 dima. All rights reserved.
//

#import "DSVersionsTableViewController.h"
#import "DSMainViewController.h"
#import "DSMainTableViewCell.h"
#import "DSCategoryTableViewCell.h"
#import "DSRateView.h"
#import "NFXIntroViewController.h"
#import "DSSong.h"
#import "UIView+AnimateHidden.h"

typedef enum {
    DSSongSearch,
    DSArtistSearch
}DSSortType;

@interface DSMainViewController () <DSRateViewDelegate, UISearchBarDelegate>

@property (strong, nonatomic) PFRelation* relation;
@property (strong, nonatomic) NSMutableArray* musicObjects;
@property (strong, nonatomic) NSArray* categories;
@property (assign, nonatomic) NSInteger activeItem;
@property (assign, nonatomic) NSInteger playItem;
@property (strong, nonatomic) NSTimer* playTimer;
@property (assign, nonatomic) NSInteger selectedRow;
@property (assign, nonatomic) NSInteger selectedTab;
@property (strong, nonatomic) NSString* selectCategory;
@property (strong, nonatomic) UIBarButtonItem* navBarItem;
@property (assign, nonatomic) NSInteger selectedSearch;
@property (weak,nonatomic) UISearchBar *searchBar;
@property (strong , nonatomic) UIView* titleView;
@property (assign , nonatomic) BOOL reloadData;
@property (assign , nonatomic) BOOL loadingData;

@end

@implementation DSMainViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"bg.jpg"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
     self.titleView = self.navigationItem.titleView;
    
    UIImage *btnImg = [UIImage imageNamed:@"button_set_up.png"];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0.f, 0.f, btnImg.size.width, btnImg.size.height);
    [btn setImage:btnImg forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(showInstruction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = item;
    
    
    btnImg = [UIImage imageNamed:@"button_back.png"];
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0.f, 0.f, btnImg.size.width, btnImg.size.height);
    [btn setImage:btnImg forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navBarItem = item;
    
    [self setSearchItem];
    
    [self.tabbar setSelectedItem:[self.tabbar.items objectAtIndex:0]];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    self.selectedRow = -1;
    
    [self loadDataForSortType:@"top"];
    [DSSoundManager sharedManager].delegate = self;
    self.playTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
    
    
    
}
  
- (void)viewWillDisappear:(BOOL)animated
{
    [DSSoundManager sharedManager].delegate = nil;
    [self.playTimer invalidate];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark - UITableViewDataSource


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.reloadData) {
        return 0;
    } else {
        if (self.selectedTab == 2 && self.selectCategory == nil){
            return  [ self.categories count];
        } else {
            return  [self.musicObjects count];

        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *mainTableIdentifier = @"mainCell";
    static NSString *categoryIdentifier = @"category";
    
    if (self.selectedTab ==2 && self.selectCategory == nil){
    
       DSCategoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:categoryIdentifier];
        if (cell == nil) {
            cell = [[DSCategoryTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:mainTableIdentifier];
            
        }
       NSString* object = [self.categories objectAtIndex:indexPath.row];
        cell.categoryLabel.text = object  ;
        return cell;
    }else{
        
        
        
    DSMainTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:mainTableIdentifier];
    if (cell == nil) {
        cell = [[DSMainTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:mainTableIdentifier];
    }
    
    if (self.selectedTab == 3) {
        DSSong*   song = [self.musicObjects objectAtIndex:indexPath.row];
        cell.rateView.rating = [song.rate floatValue];
        cell.artistLabel.text = song.author;
        cell.titleLabel.text = song.name;
    } else {
        PFObject* object = [self.musicObjects objectAtIndex:indexPath.row];
        cell.rateView.rating = [[object objectForKey:@"rate"] floatValue];
        cell.artistLabel.text = [object objectForKey:@"author"];
        cell.titleLabel.text = [object objectForKey:@"name"];
    }
    cell.rateView.delegate = self;
    cell.rateView.editable = YES;
    cell.rateView.notSelectedImage = [UIImage imageNamed:@"heart_empty@2x.png"];
    cell.rateView.halfSelectedImage =  [UIImage imageNamed:@"heart_half@2x.png"];
    cell.rateView.fullSelectedImage = [UIImage imageNamed:@"heart_full@2x.png"];
    cell.rateView.maxRating = 5;
    
    if (self.selectedRow != indexPath.row) {
        [cell.rateView setHidden:YES];
    }
   
    cell.downloadBtn.tag = indexPath.row;
    [cell.downloadBtn addTarget:self action:@selector(downloadClicked:)
               forControlEvents:UIControlEventTouchUpInside];
    
    
    
    cell.uaprogressBtn.fillOnTouch = YES;
    cell.uaprogressBtn.tintColor = [UIColor whiteColor];
    cell.uaprogressBtn.borderWidth = 2.0;
     cell.uaprogressBtn.lineWidth = 2.0;
    
    UIImageView *triangle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 35)];
    [triangle setImage:[UIImage imageNamed: @"triangle.png"] ];
    cell.uaprogressBtn.centralView = triangle;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 48.0, 18.0)];
    label.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:14];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = cell.uaprogressBtn.tintColor;
    label.backgroundColor = [UIColor clearColor];



    cell.uaprogressBtn.progressChangedBlock = ^(UAProgressView *progressView, CGFloat progress) {
        if ([progressView.centralView isKindOfClass:[UILabel class]]){
            if (progress == 0) progress = 0.01;
            [(UILabel *)progressView.centralView setText:[NSString stringWithFormat:@"%2.0f%%", progress * 100]];
        }
    };
    
    cell.uaprogressBtn.fillChangedBlock = ^(UAProgressView *progressView, BOOL filled, BOOL animated){
        UIColor *color = (filled ? [UIColor greenColor] : progressView.tintColor);
        progressView.centralView =label;
            if (animated) {
                [UIView animateWithDuration:0.3 animations:^{
                    [(UILabel *)progressView.centralView setTextColor:color];
                }];
            } else {
                [(UILabel *)progressView.centralView setTextColor:color];
            }
        
    };
    
    
    cell.uaprogressBtn.didSelectBlock = ^(UAProgressView *progressView){
        
        if (indexPath.row == self.playItem && [[DSSoundManager sharedManager] isPlaying]) {
            
            [[DSSoundManager sharedManager] pause];
        }
        else
            [self downloadAndPlay:indexPath.row forView:progressView];
        
    };
    
    cell.versionBtn.hidden = YES;
    
    return cell;
    }
}


#pragma marm - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   
    DSVersionsTableViewController* vc = [segue destinationViewController];
    vc.childrens = self.relation;
   
}

#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if (self.selectCategory != nil){
    
        PFObject *object = [self.musicObjects objectAtIndex:indexPath.row];
        self.relation = [object relationForKey:@"versions"];
        
    }
    return indexPath;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.selectedTab == 2 && self.selectCategory == nil){
        return 50;
    } else {
        if ([indexPath isEqual:[tableView indexPathForSelectedRow]])
        {
            return 125.0f;
        }  else {
          
            return 80;
            
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    if (self.selectedTab == 2  && self.selectCategory == nil){
        DSCategoryTableViewCell* cell =( DSCategoryTableViewCell*)  [self.tableView cellForRowAtIndexPath:indexPath];
        self.selectCategory  = cell.categoryLabel.text;
        self.selectedRow = -1;
        [self loadCategory:self.selectCategory];

    } else {
       // DSMainTableViewCell* cell =( DSMainTableViewCell*)  [self.tableView cellForRowAtIndexPath:indexPath];
      //  [cell.rateView setHidden:NO];
     //   NSMutableArray *modifiedRows = [NSMutableArray array];
      //  [modifiedRows addObject:indexPath];
      //  [tableView reloadRowsAtIndexPaths:modifiedRows withRowAnimation: UITableViewRowAnimationAutomatic];
        NSIndexPath *myIP = [NSIndexPath indexPathForRow:self.selectedRow inSection:0];
        DSMainTableViewCell *cell = ( DSMainTableViewCell*)[tableView cellForRowAtIndexPath:myIP];
        if (cell.rateView.hidden == NO){
            
            [cell.rateView setHiddenAnimated:YES delay:0 duration:0.3];
            
        }
        [tableView beginUpdates];
        [self animateCell:indexPath andTableView:tableView];
        [tableView endUpdates];
    }
     self.selectedRow = indexPath.row;
}

#pragma mark - Self Methods
- (void)animateCell:(NSIndexPath*)indexPath andTableView:(UITableView*)tableView
{
    [UIView animateWithDuration:0.5f animations: ^
     {
         DSMainTableViewCell *cell = ( DSMainTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        // [cell.rateView setHidden:NO ];

         CGRect rect = cell.frame;
         rect.size.height = 125.0f;
         cell.frame = rect;
         //NSLog(@"%f", cell.frame.size.height);
     }];
    DSMainTableViewCell *cell = ( DSMainTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    [cell.rateView setHiddenAnimated:NO delay:0 duration:1];
}
- (void)searchShow:(UIBarButtonItem *)sender {
    
    UIBarButtonSystemItem item = UIBarButtonSystemItemEdit;
    
    if ([self.navigationItem.titleView isKindOfClass:[UISearchBar class]]) {
        
        item = UIBarButtonSystemItemSearch;
        
        UISegmentedControl *control = [[UISegmentedControl alloc]initWithItems:@[@"Song",@"Artist"]];
        [control addTarget:self action:@selector(searchSongsControl:) forControlEvents:UIControlEventValueChanged];
        control.selectedSegmentIndex = self.selectedSearch;
       
        self.navigationItem.titleView = control;
        
    } else {
        
        UISearchBar *searchBar = [[UISearchBar alloc]init];
        self.searchBar = searchBar;
        self.searchBar.delegate = self;
        self.navigationItem.titleView = self.searchBar;
        
    }
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:item target:self action:@selector(searchShow:)];
    
    [self.navigationItem setLeftBarButtonItem:leftButton animated:YES];
    
}

- (void)searchSongsControl:(UISegmentedControl *)sender {
    
    self.selectedSearch = sender.selectedSegmentIndex;
    
}


- (void) downloadClicked:(id)sender {
    
    UIButton* btn = sender;
    PFObject *object = [self.musicObjects objectAtIndex:btn.tag];
    PFFile *soundFile = object[@"mfile"];
    [soundFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
         if (!error) {
             NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
             NSString *documentsDirectory = [paths objectAtIndex:0];
             
             NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:soundFile.name];
             [data writeToFile:fullPath options:NSDataWritingWithoutOverwriting error:nil];
             [[DSSoundManager sharedManager] addSongToDownloads:object fileUrl:fullPath];
             //NSLog(@"Data Ok");
         }
    } ];
}
- (void) downloadAndPlay:(NSUInteger) row forView:(UAProgressView*) progressView {
    
    self.activeItem = row;
    PFObject *object = [self.musicObjects objectAtIndex:row];
    PFFile *soundFile = object[@"mfile"];
    [soundFile getDataInBackgroundWithBlock:^(NSData *soundData, NSError *error) {
        
        if(self.playItem!=self.activeItem ) {
            NSIndexPath* activeRow = [NSIndexPath indexPathForRow:self.playItem inSection:0];
            DSMainTableViewCell* cell =( DSMainTableViewCell*)  [self.tableView cellForRowAtIndexPath:activeRow];
            
            UIImageView *triangle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 35)];
            [triangle setImage:[UIImage imageNamed: @"triangle.png"] ];
            cell.uaprogressBtn.centralView = triangle;
            [cell.uaprogressBtn setProgress:0];
        }
        
        if (!error) {
        
            self.playItem = row;
            [[DSSoundManager sharedManager] playSong:soundData];
            
        }
        
    }
    progressBlock:^(int percentDone) {
        dispatch_async(dispatch_get_main_queue(), ^{
                                   
                    [progressView setProgress: (float) percentDone/100];
        });
    }];
}

- (void) setSearchItem {
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchShow:)];
    item.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = item;
    
}

- (void) back {
    [self setSearchItem];
    self.selectCategory = nil;
    self.reloadData = YES;
    [self.tableView reloadData];
    self.reloadData = NO;
    [self loadCategories];
}

- (void) loadCategory:(NSString*) category {
   
    self.navigationItem.leftBarButtonItems  = @[self.navBarItem ];
    
    self.navigationItem.title = category;
    PFQuery *query = [PFQuery queryWithClassName:@"Music"];
    [query whereKey:@"ganre" equalTo:category];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            self.musicObjects = [NSMutableArray arrayWithArray:objects];
            self.reloadData = YES;
            [self.tableView reloadData];
            self.reloadData = NO;
            [self reloadMusicObjects];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
}
- (void) loadDownloads {
    
    self.musicObjects = [[DSSoundManager sharedManager] getDownloads];
    [self reloadMusicObjects];
}

- (void) loadCategories {
    
    if ([self.categories count] == 0 ) {
        PFQuery *query = [PFQuery queryWithClassName:@"Music"];
        [query selectKeys:@[@"ganre"]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
         if (!error) {
             self.categories = [objects valueForKeyPath:@"@distinctUnionOfObjects.ganre"];
             [self reloadCategories];
             
         } else {
             // Log details of the failure
             NSLog(@"Error: %@ %@", error, [error userInfo]);
         }
        }];
    } else {
        [self reloadCategories];
    }
    
}
- (void) reloadCategories {
    NSMutableArray* newPaths = [NSMutableArray array];
    for (int i =0 ; i < [self.categories count]; i++) {
        [newPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:newPaths withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];

}

- (void) reloadMusicObjects {
    NSMutableArray* newPaths = [NSMutableArray array];
    for (int i =0 ; i < [self.musicObjects count]; i++) {
        [newPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:newPaths withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    
}
- (void)getDataFromServer {
    
    if (self.loadingData != YES) {
        
        self.loadingData = YES;
        PFQuery *query = [PFQuery queryWithClassName:@"Music"];
        query.skip = [self.musicObjects count];
        query.limit = 20;
     //   if ([key isEqualToString:@"top"]){
            [query orderByDescending:@"rate"];
    //    }
     //   if ([key isEqualToString:@"new"]){
            [query orderByDescending:@"createdAt"];
            
      //  }
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                
                [self.musicObjects addObjectsFromArray:objects];
                NSMutableArray* newPaths = [NSMutableArray array];
                for (int i = (int)[self.musicObjects count] - (int)[objects count]; i < [self.musicObjects count]; i++) {
                    [newPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                }
                
                [self.tableView beginUpdates];
                [self.tableView insertRowsAtIndexPaths:newPaths withRowAnimation:UITableViewRowAnimationNone];
                [self.tableView endUpdates];
                
                 self.loadingData = NO;
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
                self.loadingData = NO;
            }
        }];
       
                
        
                
        
    }
}

- (void) loadDataForSortType:(NSString*) key{
    
    PFQuery *query = [PFQuery queryWithClassName:@"Music"];
   // query.maxCacheAge = 60 * 60 * 24;
   // query.cachePolicy = kPFCachePolicyNetworkElseCache;
    query.limit = 20;
    if ([key isEqualToString:@"top"]){
        [query orderByDescending:@"rate"];
    }
    if ([key isEqualToString:@"new"]){
        [query orderByDescending:@"createdAt"];
        
    }
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            self.musicObjects = [NSMutableArray arrayWithArray:objects];
        
            [self reloadMusicObjects];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void) showInstruction {
    
    UIImage*i1 = [UIImage imageNamed:@"1.png"];
    UIImage*i2 = [UIImage imageNamed:@"2.png"];
    UIImage*i3 = [UIImage imageNamed:@"3.png"];
    UIImage*i4 = [UIImage imageNamed:@"4.png"];
    UIImage*i5 = [UIImage imageNamed:@"5.png"];
    UIImage*i6 = [UIImage imageNamed:@"6.png"];
    UIImage*i7 = [UIImage imageNamed:@"7.png"];
    UIImage*i8 = [UIImage imageNamed:@"8.png"];
    UIImage*i9 = [UIImage imageNamed:@"9.png"];
    
    NFXIntroViewController*vc = [[NFXIntroViewController alloc] initWithViews:@[i1,i2,i3,i4,i5,i2,i6,i7,i8,i9]];
    [self presentViewController:vc animated:true completion:nil];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= self.tableView.contentSize.height - scrollView.frame.size.height/2) {
        if (!self.loadingData) {
           [self getDataFromServer];
            NSLog(@"%f , %f,  %f",scrollView.contentOffset.y,scrollView.frame.size.height , self.tableView.contentSize.height);
       }
    }
}

#pragma mark - DSSoundManagerDelegate
- (void) statusChanged:(BOOL) playStatus {
   NSIndexPath* activeRow = [NSIndexPath indexPathForRow:self.playItem inSection:0];
    DSMainTableViewCell* cell =( DSMainTableViewCell*)  [self.tableView cellForRowAtIndexPath:activeRow];
   
    if (playStatus == YES){
        UIImageView *square = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [square setImage:[UIImage imageNamed: @"square.png"] ];
        cell.uaprogressBtn.centralView = square;
    }
    else{
        
        UIImageView *triangle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 35)];
        [triangle setImage:[UIImage imageNamed: @"triangle.png"] ];
        cell.uaprogressBtn.centralView = triangle;

    }
}

#pragma mark - Timer
- (void) timerAction:(id)timer{

    if( [[DSSoundManager sharedManager] isPlaying]) {
        NSIndexPath* activeRow = [NSIndexPath indexPathForRow:self.playItem inSection:0];
        DSMainTableViewCell* cell =( DSMainTableViewCell*)  [self.tableView cellForRowAtIndexPath:activeRow];
   
        [cell.uaprogressBtn setProgress:[DSSoundManager sharedManager].getCurrentProgress];
   
    }
}

#pragma mark - UITabBarDelegate
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    if ([self.navigationItem.titleView isKindOfClass:[UISearchBar class]] ||[self.navigationItem.titleView isKindOfClass:[UISegmentedControl class]]) {
        self.navigationItem.titleView = self.titleView;
    }
    self.reloadData = YES;
    [self.tableView reloadData];
    self.reloadData = NO;
    self.selectedTab = tabBar.selectedItem.tag;
    self.selectedRow = -1;
    switch (tabBar.selectedItem.tag) {
            
        case 0:{
            [self setSearchItem];
            self.navigationItem.title = @"Тop";
            [self loadDataForSortType:@"top"];
            break;
        }
         
        case 1:{
            [self setSearchItem];
            self.navigationItem.title = @"New";
            [self loadDataForSortType:@"new"];
            break;
        }
            
        case 2:{
            self.navigationItem.leftBarButtonItem = nil;
            self.navigationItem.title = @"Categories";
            [self loadCategories];
            break;
        }
            
        case 3:{
            self.navigationItem.leftBarButtonItem = nil;
            self.navigationItem.title = @"Downloads";
            [self loadDownloads];
            break;
        }
        
        
    }
    
}

#pragma mark - DSRateViewDelegate

- (void)rateView:(DSRateView *)rateView ratingDidChange:(float)rating{
    
    
}
#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSString* searchKey;
    if (self.selectedSearch == 0){
        searchKey = @"name" ;
    } else {
        searchKey = @"author";
    }
   
    PFQuery *queryCapitalizedString = [PFQuery queryWithClassName:@"Music"];
    [queryCapitalizedString whereKey:searchKey containsString:[searchBar.text capitalizedString]];
    
    //query converted user text to lowercase
    PFQuery *queryLowerCaseString = [PFQuery queryWithClassName:@"Music"];
    [queryLowerCaseString whereKey:searchKey containsString:[searchBar.text lowercaseString]];
    
    //query real user text
    PFQuery *querySearchBarString = [PFQuery queryWithClassName:@"Music"];
    [querySearchBarString whereKey:searchKey containsString:searchBar.text];
    
    PFQuery *finalQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:queryCapitalizedString,queryLowerCaseString, querySearchBarString,nil]];
    
    [finalQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            self.musicObjects = objects;
            
            [self.tableView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}
@end
