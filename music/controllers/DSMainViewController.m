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


@interface DSMainViewController () < UISearchBarDelegate , DSRateViewDelegate  >


@property (strong, nonatomic) PFRelation* relation;
@property (strong, nonatomic) NSArray* categories;
@property (assign, nonatomic) NSInteger selectedTab;
@property (strong, nonatomic) NSString* selectCategory;
@property (strong, nonatomic) UIBarButtonItem* navBarBackItem;
@property (strong, nonatomic) UIBarButtonItem* rightBarButtonItem;
@property (weak  , nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UIView* titleView;
@property (assign, nonatomic) BOOL reloadData;
@property (assign, nonatomic) BOOL loadingData;

@end

@implementation DSMainViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.automaticallyAdjustsScrollViewInsets =  NO;
    [self.navigationItem setTitle:@"top Rated"];
    
    
 
    UIImage *btnImg = [UIImage imageNamed:@"back@3x.png"];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0.f, 0.f, btnImg.size.width, btnImg.size.height);
    [btn setImage:btnImg forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navBarBackItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.rightBarButtonItem = self.navigationItem.rightBarButtonItem;
    [self setSearchItem];
    
    UITabBarItem * tbi = [self.tabbar.items objectAtIndex:0];
    tbi.selectedImage = [UIImage imageNamed:@"top_s@3x.png"];
    UITabBarItem * tbi1 = [self.tabbar.items objectAtIndex:1];
    tbi1.selectedImage = [UIImage imageNamed:@"new_s@3x.png"];
    UITabBarItem * tbi2 = [self.tabbar.items objectAtIndex:2];
    tbi2.selectedImage = [UIImage imageNamed:@"categories_s@3x.png"];
    UITabBarItem * tbi3 = [self.tabbar.items objectAtIndex:3];
    tbi3.selectedImage = [UIImage imageNamed:@"downloads_s@3x.png"];
    for (UITabBarItem *tbi in self.tabbar.items) {
        tbi.image = [tbi.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        tbi.selectedImage = [tbi.selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    self.selectedRow = -1;
    self.playItem = -1;
    
    [self loadDataForSortType:@"top"];
    [self.tabbar setSelectedItem:[self.tabbar.items objectAtIndex:0]];
    
    
   
}


- (void) viewWillAppear:(BOOL)animated {
    
    switch (self.selectedTab) {
        case 0:
            self.navigationItem.title = @"top Rated";
            break;
        case 1:
            self.navigationItem.title = @"New";
            break;
        case 2:
            self.navigationItem.title = @"Categories";
            break;
        case 3:
            self.navigationItem.title = @"Downloads";
            break;
        default:
            break;
    }
    
    [super viewWillAppear:animated];

    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
   
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
        
    cell.rateView.delegate = self;
    cell.rateView.tag = indexPath.row;
    cell.rateView.notSelectedImage = [UIImage imageNamed:@"heart_empty.png"];
    cell.rateView.halfSelectedImage =  [UIImage imageNamed:@"heart_half.png"];
    cell.rateView.fullSelectedImage = [UIImage imageNamed:@"heart_full.png"];
        
    cell.rateView.maxRating = 5;
    if (self.selectedTab == 3) {
        DSSong* song = [self.musicObjects objectAtIndex:indexPath.row];
        cell.rateView.rating = [song.rate floatValue];
        cell.artistLabel.text = song.author;
        cell.titleLabel.text = song.name;
        if ([[DSSoundManager sharedManager] existsLikeForSongID:song.idSong]){
            cell.rateView.editable = NO;
            cell.rateView.alpha = 0.5;
        } else {
            cell.rateView.editable = YES;
            cell.rateView.alpha = 1;
        }
        [cell.downloadBtn setImage:[UIImage imageNamed:@"complete@3x.png"] forState: UIControlStateNormal];

    } else {
        PFObject* object = [self.musicObjects objectAtIndex:indexPath.row];
        cell.rateView.rating = [[object objectForKey:@"rate"] floatValue];
        cell.artistLabel.text = [object objectForKey:@"author"];
        cell.titleLabel.text = [object objectForKey:@"name"];
        if ([[DSSoundManager sharedManager] existsLikeForSongID:object.objectId]) {
            cell.rateView.editable = NO;
            cell.rateView.alpha = 0.5;
        } else {
            cell.rateView.editable = YES;
            cell.rateView.alpha = 1;
        }

        if ([[DSSoundManager sharedManager] existsSongInDownloads:object.objectId]) {
            [cell.downloadBtn setImage:[UIImage imageNamed:@"complete@3x.png"] forState: UIControlStateNormal];
        } else {
            [cell.downloadBtn setImage:[UIImage imageNamed:@"download@3x.png"] forState: UIControlStateNormal];

        }
    }
   
        
    if (self.selectedRow != indexPath.row) {
        [cell.rateView setHidden:YES];
        [cell.versionBtn setHidden:YES];
    } else {
        [cell.rateView setHidden:NO];
        [cell.versionBtn setHidden:NO];
    }
   
    
    cell.downloadBtn.tag = indexPath.row;
    [cell.downloadBtn addTarget:self action:@selector(downloadClicked:)
               forControlEvents:UIControlEventTouchUpInside];
    
    cell.uaprogressBtn.tag = indexPath.row;
    cell.uaprogressBtn.fillOnTouch = YES;
    cell.uaprogressBtn.tintColor = [UIColor whiteColor];
    cell.uaprogressBtn.borderWidth = 1.5;
    cell.uaprogressBtn.lineWidth = 2.0;
    
   
    UIColor* playColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"circle_play.png"]];
    UIColor* stopColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"circle_stop.png"]];
    UIImageView *triangle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    [triangle setImage:[UIImage imageNamed: @"triangle.png"] ];
        
    UIImageView *square = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [square setImage:[UIImage imageNamed: @"square.png"] ];
        
    if (indexPath.row != self.playItem) {
        cell.uaprogressBtn.centralView = triangle;
        cell.uaprogressBtn.backgroundColor = playColor;
        [cell.uaprogressBtn setProgress:0];
    } else {
        [cell.uaprogressBtn setProgress:[DSSoundManager sharedManager].getCurrentProgress];
        if ([[DSSoundManager sharedManager] isPlaying]) {
            cell.uaprogressBtn.centralView = square;
            cell.uaprogressBtn.backgroundColor = stopColor;
        } else {
            cell.uaprogressBtn.centralView = triangle;
            cell.uaprogressBtn.backgroundColor = playColor;
        }
    }
    cell.uaprogressBtn.tag = indexPath.row;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 48.0, 18.0)];
    label.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:14];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = cell.uaprogressBtn.tintColor;
    label.backgroundColor = [UIColor clearColor];
        
    cell.uaprogressBtn.cancelSelectBlock =  ^(UAProgressView *progressView) {
       // NSLog(@"%ld , %ld", (long)self.playItem, (long)progressView.tag);
        if (![progressView.centralView isKindOfClass:[UIImageView class]]){
            if ( progressView.tag == self.playItem && [[DSSoundManager sharedManager] isPlaying]) {
                cell.uaprogressBtn.centralView = square;
                cell.uaprogressBtn.backgroundColor = stopColor;
            } else {
                cell.uaprogressBtn.centralView = triangle;
                cell.uaprogressBtn.backgroundColor = playColor;
            }
        }
    };
        
   
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
    
    return cell;
    }
}


#pragma marm - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   
    DSVersionsTableViewController* vc = [segue destinationViewController];
    vc.musicObject =  [self.musicObjects objectAtIndex:self.selectedRow];
   
}

#pragma mark - UITableViewDelegate
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedTab == 3 ) {
        return YES;
    } else {
        return NO;
    }
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        
        DSSong *deleteSong = [self.musicObjects objectAtIndex:indexPath.row ];
        
        [self.musicObjects removeObject:deleteSong];
        
        
        [[DSSoundManager sharedManager] deleteSong:deleteSong.idSong];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        
    }
}
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
        if(indexPath.row == self.selectedRow){
            return 125.0f;
        }  else {
            return 80;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectedTab == 2  && self.selectCategory == nil){
        DSCategoryTableViewCell* cell = (DSCategoryTableViewCell*)  [self.tableView cellForRowAtIndexPath:indexPath];
        self.selectCategory = cell.categoryLabel.text;
        self.selectedRow = -1;
        [self loadCategory:self.selectCategory];
    } else {
        [self selectRow:indexPath];
    }
 
}

#pragma mark - Self methods

- (void) editMode {
    
    
    self.tableView.editing = !self.tableView.editing;
    if (self.tableView.editing){
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemDone target:self action:@selector(editMode)];
    }
    else{
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemEdit target:self action:@selector(editMode)];
    }
}


- (void) selectRow:(NSIndexPath *) indexPath {
    if (self.selectedRow != indexPath.row) {
        NSIndexPath *myIP = [NSIndexPath indexPathForRow:self.selectedRow inSection:0];
        DSMainTableViewCell *cell = (DSMainTableViewCell*) [self.tableView cellForRowAtIndexPath:myIP];
        if (cell.rateView.hidden == NO){
            [cell.rateView setHiddenAnimated:YES editable:cell.rateView.editable delay:0 duration:0.3];
            [cell.versionBtn setHiddenAnimated:YES editable:YES delay:0 duration:0.3];
        }
        self.selectedRow = indexPath.row;
        [self.tableView beginUpdates];
        [self animateCell:indexPath andTableView:self.tableView];
        [self.tableView endUpdates];
    }
}

- (void)animateCell:(NSIndexPath*)indexPath andTableView:(UITableView*)tableView
{
    [UIView animateWithDuration:0.5f animations: ^
     {
         DSMainTableViewCell *cell = ( DSMainTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];

         CGRect rect = cell.frame;
         rect.size.height = 125.0f;
         cell.frame = rect;

     }];
    DSMainTableViewCell *cell = ( DSMainTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    [cell.rateView setHiddenAnimated:NO editable:cell.rateView.editable delay:0 duration:1];
    [cell.versionBtn setHiddenAnimated:NO editable:YES  delay:0 duration:1];
}


- (void)searchShow:(UIBarButtonItem *)sender {
    
    UISearchBar *searchBar = [[UISearchBar alloc]init];
    UIImage *searchFieldImage = [[UIImage imageNamed:@"ic_search_red@3x.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    //UITextField *searchField = [searchBar valueForKey:@"_searchField"];
    //searchField.textColor = [UIColor redColor];
   
    [searchBar setImage:searchFieldImage forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    self.searchBar = searchBar;
    self.searchBar.delegate = self;
    self.navigationItem.titleView = self.searchBar;
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
    
}


- (void) downloadAndPlay:(NSUInteger) row forView:(UAProgressView*) progressView {
    
    self.activeItem = row;
    PFObject *object = [self.musicObjects objectAtIndex:row];
   
    [self selectRow:[NSIndexPath indexPathForRow:row inSection:0]];
    
    if (![object isKindOfClass:[PFObject class]]) {
        DSSong* song = [self.musicObjects objectAtIndex:row];
        NSLog(@"%@",[NSURL fileURLWithPath:song.link]);
        NSData * data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:song.link]];
        if (data != nil) {
             self.playItem = row;
            [[DSSoundManager sharedManager] playSong: data] ;
        } else {
            NSIndexPath* activeRow = [NSIndexPath indexPathForRow:row inSection:0];
            DSMainTableViewCell* cell =( DSMainTableViewCell*)  [self.tableView cellForRowAtIndexPath:activeRow];
            UIImageView *triangle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
            [triangle setImage:[UIImage imageNamed: @"triangle.png"] ];
            cell.uaprogressBtn.centralView = triangle;
            cell.uaprogressBtn.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"circle_play.png"]];
            [cell.uaprogressBtn setProgress:0];
        }
    }
    else {
         PFFile *soundFile = object[@"mfile"];
        [soundFile getDataInBackgroundWithBlock:^(NSData *soundData, NSError *error) {
        // NSLog(@"%ld %ld", (long)self.playItem, self.activeItem);
        if(self.playItem >= 0 ) {
            NSIndexPath* activeRow = [NSIndexPath indexPathForRow:self.playItem inSection:0];
            DSMainTableViewCell* cell =( DSMainTableViewCell*)  [self.tableView cellForRowAtIndexPath:activeRow];
            UIImageView *triangle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
            [triangle setImage:[UIImage imageNamed: @"triangle.png"] ];
            cell.uaprogressBtn.centralView = triangle;
             cell.uaprogressBtn.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"circle_play.png"]];
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
}

- (void) setSearchItem {
    
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_search@3x.png"] style:UIBarButtonItemStylePlain target:self action:@selector(searchShow:)];
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
   
    self.navigationItem.leftBarButtonItems  = @[self.navBarBackItem ];
    
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
    [self removeLoading];
}

- (void) loadCategories {
    
    if ([self.categories count] == 0 ) {
        PFQuery *query = [PFQuery queryWithClassName:@"Music"];
        query.limit = 1000;
        [query selectKeys:@[@"ganre"]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
         if (!error) {
             self.categories = [objects valueForKeyPath:@"@distinctUnionOfObjects.ganre"];
             [self reloadCategories];
             [self removeLoading];
             
         } else {
    
             NSLog(@"Error: %@ %@", error, [error userInfo]);
             [self removeLoading];
         }
        }];
    } else {
        [self reloadCategories];
        [self removeLoading];
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
- (void)getAddDataFromServer:(NSString*) key {
    
    if (self.loadingData != YES) {
        
        self.loadingData = YES;
        PFQuery *query = [PFQuery queryWithClassName:@"Music"];
        query.skip = [self.musicObjects count];
        query.limit = 20;
        if ([key isEqualToString:@"top"]){
            [query orderByDescending:@"rate"];
        }
        if ([key isEqualToString:@"new"]){
            [query orderByDescending:@"createdAt"];
            
        }
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                self.loadingData = NO;
                [self.musicObjects addObjectsFromArray:objects];
                NSMutableArray* newPaths = [NSMutableArray array];
                for (int i = (int)[self.musicObjects count] - (int)[objects count]; i < [self.musicObjects count]; i++) {
                    [newPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                }
                
                [self.tableView beginUpdates];
                [self.tableView insertRowsAtIndexPaths:newPaths withRowAnimation:UITableViewRowAnimationNone];
                [self.tableView endUpdates];
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
            [self removeLoading];
            [self reloadMusicObjects];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            [self removeLoading];
        }
    }];
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.selectedTab < 2 ) {
        if (((scrollView.contentOffset.y + scrollView.frame.size.height) >= self.tableView.contentSize.height - scrollView.frame.size.height/2)  && (scrollView.contentOffset.y > 0)) {
            if (!self.loadingData) {
                if(self.selectedTab == 0 )
                    [self getAddDataFromServer:@"top"];
                else
                    [self getAddDataFromServer:@"new"];
                NSLog(@"%f , %f,  %f",scrollView.contentOffset.y,scrollView.frame.size.height , self.tableView.contentSize.height);
            }
    }
    }
}

- (void) setRate:(float) rating  forObject: (PFObject*) object  {
    double newRate = ([[object objectForKey:@"rate"] floatValue] * [[object objectForKey:@"colRates"] integerValue] + rating) / ([[object objectForKey:@"colRates"] integerValue] + 1);
    newRate = newRate - [[object objectForKey:@"rate"] floatValue] ;
    [object incrementKey:@"colRates"];
    [object incrementKey:@"rate" byAmount:[NSNumber numberWithDouble:newRate] ];
    [object saveInBackground];
}


#pragma mark - UITabBarDelegate
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    if ([self.navigationItem.titleView isKindOfClass:[UISearchBar class]]) {
        self.navigationItem.titleView = self.titleView;
    }
    if (self.navigationItem.rightBarButtonItem == nil) {
        self.navigationItem.rightBarButtonItem = self.rightBarButtonItem;
    }
    self.tableView.editing = NO;
    self.reloadData = YES;
    self.musicObjects = nil;
    [self.tableView reloadData];
    self.reloadData = NO;
    self.selectedTab = tabBar.selectedItem.tag;
    self.selectedRow = -1;
    
    
    self.playItem = -1;
    self.activeItem = -1;
    [[DSSoundManager sharedManager] pause];
    [self addLoading];
    switch (tabBar.selectedItem.tag) {
            
        case 0:{
            [self setSearchItem];
            [self.navigationItem setTitle:@"top Rated"];
            [self loadDataForSortType:@"top"];
            break;
        }
         
        case 1:{
            [self setSearchItem];
            [self.navigationItem setTitle:@"New"];
            [self loadDataForSortType:@"new"];
            break;
        }
            
        case 2:{
            self.selectCategory = nil;
            self.navigationItem.leftBarButtonItem = nil;
            self.navigationItem.title = @"Categories";
            [self loadCategories];
            break;
        }
            
        case 3:{
        
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemEdit target:self action:@selector(editMode)];
            self.navigationItem.title = @"Downloads";
            [self loadDownloads];
            break;
        }
        
        
    }
    
}


#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
   
    [searchBar setShowsCancelButton:YES animated:YES];
    UIView* view=searchBar.subviews[0];
    for (UIView *subView in view.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton *cancelButton = (UIButton*)subView;
            [cancelButton.titleLabel setFont:[UIFont fontWithName:@"laCartoonerie" size:15.0]];
        }
    }
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    
    PFQuery *querySearchBarName = [PFQuery queryWithClassName:@"Music"];
    [querySearchBarName whereKey:@"name" matchesRegex:searchBar.text modifiers:@"i" ];
    
    PFQuery *querySearchBarAuthor = [PFQuery queryWithClassName:@"Music"];
    [querySearchBarAuthor whereKey:@"author" matchesRegex:searchBar.text modifiers:@"i" ];
    
    PFQuery *finalQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects: querySearchBarName,  querySearchBarAuthor, nil]];

    [finalQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.musicObjects =(NSMutableArray*) objects;
            [self.tableView reloadData];
        } else {
      
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}
@end
