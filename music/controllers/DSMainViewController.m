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
#import "YRActivityIndicator.h"
#import "MSLiveBlur.h"
#import "GoogleWearAlertObjc.h"



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
@property (weak,nonatomic) UISearchBar *searchBar;
@property (strong , nonatomic) UIView* titleView;
@property (assign , nonatomic) BOOL reloadData;
@property (assign , nonatomic) BOOL loadingData;
@property (strong , nonatomic) YRActivityIndicator* activityIndicator;

@end

@implementation DSMainViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"2.jpg"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    
    [self.navigationItem setTitle:@"top Rated"];
    
    UIImage *btnImg = [UIImage imageNamed:@"button_set_up.png"];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0.f, 0.f, btnImg.size.width, btnImg.size.height);
    [btn setImage:btnImg forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(showInstruction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = item;
    
    btnImg = [UIImage imageNamed:@"back@3x.png"];
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0.f, 0.f, btnImg.size.width, btnImg.size.height);
    [btn setImage:btnImg forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navBarItem = item;
    
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
    
    self.activityIndicator = [[YRActivityIndicator alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    self.activityIndicator.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.height/2 - 80);
    self.activityIndicator.radius = 60;
    self.activityIndicator.maxItems = 5;
    self.activityIndicator.minItemSize = CGSizeMake(10, 10);
    self.activityIndicator.maxItemSize = CGSizeMake(35, 35);
    self.activityIndicator.itemColor = [UIColor colorWithRed:106/255.0 green:215/255.0 blue:230/255.0 alpha:1];
    
    [self addLoading];
    [self loadDataForSortType:@"top"];
    [self.tabbar setSelectedItem:[self.tabbar.items objectAtIndex:0]];
    
}

- (void) viewWillAppear:(BOOL)animated {
    
    [DSSoundManager sharedManager].delegate = self;
    self.playTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];

    [super viewWillAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [DSSoundManager sharedManager].delegate = nil;
    [self.playTimer invalidate];
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
    
    if (self.selectedTab == 3) {
        DSSong*   song = [self.musicObjects objectAtIndex:indexPath.row];
        cell.rateView.rating = [song.rate floatValue];
        cell.artistLabel.text = song.author;
        cell.titleLabel.text = song.name;
        cell.rateView.editable = [[DSSoundManager sharedManager] existsLikeForSongID:song.idSong];
        [cell.downloadBtn setImage:[UIImage imageNamed:@"complete@3x.png"] forState: UIControlStateNormal];

    } else {
        PFObject* object = [self.musicObjects objectAtIndex:indexPath.row];
        cell.rateView.rating = [[object objectForKey:@"rate"] floatValue];
        cell.artistLabel.text = [object objectForKey:@"author"];
        cell.titleLabel.text = [object objectForKey:@"name"];
        cell.rateView.editable = [[DSSoundManager sharedManager] existsLikeForSongID:object.objectId];
        if ([[DSSoundManager sharedManager] existsSongInDownloads:object.objectId]) {
            [cell.downloadBtn setImage:[UIImage imageNamed:@"complete@3x.png"] forState: UIControlStateNormal];
            
        }
    }
    cell.rateView.delegate = self;
    cell.rateView.editable = YES;
    cell.rateView.tag = indexPath.row;
    cell.rateView.notSelectedImage = [UIImage imageNamed:@"heart_empty.png"];
    cell.rateView.halfSelectedImage =  [UIImage imageNamed:@"heart_half.png"];
    cell.rateView.fullSelectedImage = [UIImage imageNamed:@"heart_full.png"];
    cell.rateView.maxRating = 5;
        
    if (self.selectedRow != indexPath.row) {
        [cell.rateView setHidden:YES];
        [cell.versionBtn setHidden:YES];
    }
   
    
    cell.downloadBtn.tag = indexPath.row;
    [cell.downloadBtn addTarget:self action:@selector(downloadClicked:)
               forControlEvents:UIControlEventTouchUpInside];
    
    cell.uaprogressBtn.fillOnTouch = YES;
        cell.uaprogressBtn.tintColor = [UIColor colorWithRed:0/255.0 green:153/255.0 blue:169/255.0 alpha:1];
    cell.uaprogressBtn.borderWidth = 2.0;
    cell.uaprogressBtn.lineWidth = 2.0;
    
    UIImageView *triangle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 35)];
    [triangle setImage:[UIImage imageNamed: @"triangle.png"] ];
        
    UIImageView *square = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [square setImage:[UIImage imageNamed: @"square.png"] ];
        
    if (indexPath.row != self.playItem) {
        cell.uaprogressBtn.centralView = triangle;
        [cell.uaprogressBtn setProgress:0];
    } else {
        [cell.uaprogressBtn setProgress:[DSSoundManager sharedManager].getCurrentProgress];
        if ([[DSSoundManager sharedManager] isPlaying]) {
            cell.uaprogressBtn.centralView = square;
        } else {
            cell.uaprogressBtn.centralView = triangle;
        }
    }
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 48.0, 18.0)];
    label.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:14];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = cell.uaprogressBtn.tintColor;
    label.backgroundColor = [UIColor clearColor];
        
    cell.uaprogressBtn.cancelSelectBlock =  ^(UAProgressView *progressView) {
        if (![progressView.centralView isKindOfClass:[UIImageView class]]){
            if ( progressView.tag == self.playItem) {
                cell.uaprogressBtn.centralView = triangle;
            } else {
                cell.uaprogressBtn.centralView = square;
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
        DSCategoryTableViewCell* cell =( DSCategoryTableViewCell*)  [self.tableView cellForRowAtIndexPath:indexPath];
        self.selectCategory  = cell.categoryLabel.text;
        self.selectedRow = -1;
        [self loadCategory:self.selectCategory];
    } else {
        [self selectRow:indexPath];
    }
 
}

#pragma mark - Self Methods
- (void) selectRow:(NSIndexPath *) indexPath {
    if (self.selectedRow != indexPath.row) {
        NSIndexPath *myIP = [NSIndexPath indexPathForRow:self.selectedRow inSection:0];
        DSMainTableViewCell *cell = ( DSMainTableViewCell*)[self.tableView cellForRowAtIndexPath:myIP];
        if (cell.rateView.hidden == NO){
            [cell.rateView setHiddenAnimated:YES delay:0 duration:0.3];
            [cell.versionBtn setHiddenAnimated:YES delay:0 duration:0.3];
        }
        self.selectedRow = indexPath.row;
        [self.tableView beginUpdates];
        [self animateCell:indexPath andTableView:self.tableView];
        [self.tableView endUpdates];
    }
}
- (void)addLoading{
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [self.tableView addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];

}

- (void)removeLoading{
    
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    [self.activityIndicator stopAnimating];
    [self.activityIndicator removeFromSuperview];
    
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
    [cell.rateView setHiddenAnimated:NO delay:0 duration:1];
    [cell.versionBtn setHiddenAnimated:NO delay:0 duration:1];
}


- (void)searchShow:(UIBarButtonItem *)sender {
    
    UISearchBar *searchBar = [[UISearchBar alloc]init];
    UIImage *searchFieldImage = [[UIImage imageNamed:@"ic_search_green@3x.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    //UITextField *searchField = [searchBar valueForKey:@"_searchField"];
    //searchField.textColor = [UIColor redColor];
   
    [searchBar setImage:searchFieldImage forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    self.searchBar = searchBar;
    self.searchBar.delegate = self;
    self.navigationItem.titleView = self.searchBar;
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
    
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
             [object incrementKey:@"colDownloads"];
             [object saveInBackground];
             [self changeDownloadIcon:btn.tag];
        }
    } ];
}

- (void) changeDownloadIcon:(NSInteger) row {
   
         [UIView animateWithDuration:0.5f animations: ^
     {
          NSIndexPath* indexPath = [in]
         DSMainTableViewCell *cell = ( DSMainTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];

         [cell.downloadBtn setImage:[UIImage imageNamed:@"complete@3x.png"] forState: UIControlStateNormal];

     }];
}
- (void) downloadAndPlay:(NSUInteger) row forView:(UAProgressView*) progressView {
    
    self.activeItem = row;
    PFObject *object = [self.musicObjects objectAtIndex:row];
    PFFile *soundFile = object[@"mfile"];
    [self selectRow:[NSIndexPath indexPathForRow:row inSection:0]];
   
    [soundFile getDataInBackgroundWithBlock:^(NSData *soundData, NSError *error) {
       // NSLog(@"%ld %ld", (long)self.playItem, self.activeItem);
        if(self.playItem >= 0 ) {
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
    [self removeLoading];
}

- (void) loadCategories {
    
    if ([self.categories count] == 0 ) {
        PFQuery *query = [PFQuery queryWithClassName:@"Music"];
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
    if (self.selectedTab < 2 ) {
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= self.tableView.contentSize.height - scrollView.frame.size.height/2) {
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
            self.navigationItem.leftBarButtonItem = nil;
            self.navigationItem.title = @"Downloads";
            [self loadDownloads];
            break;
        }
        
        
    }
    
}

#pragma mark - DSRateViewDelegate

- (void)rateView:(DSRateView *)rateView ratingDidChange:(float)rating{
    PFObject *object = [self.musicObjects objectAtIndex:rateView.tag];
    UIImage *image;
    double newRate = ([[object objectForKey:@"rate"] floatValue] * [[object objectForKey:@"colRates"] integerValue] + rating) / ([[object objectForKey:@"colRates"] integerValue] + 1);
    newRate = newRate - [[object objectForKey:@"rate"] floatValue] ;
    [object incrementKey:@"colRates"];
    [object incrementKey:@"rate" byAmount:[NSNumber numberWithDouble:newRate] ];
    [object saveInBackground];
    if (rating < 2) {
        image = [UIImage imageNamed:@"sad_heart.png"];
    } else if (rating < 4) {
        image = [UIImage imageNamed:@"neutral_heart.png"];
    } else {
        image = [UIImage imageNamed:@"smile_heart.png"];
    }
    [[GoogleWearAlertObjc getInstance]prepareNotificationToBeShown:[[GoogleWearAlertViewObjc alloc]initWithTitle:nil andImage:image andWithType:Message andWithDuration:2.5 inViewController:self atPostion:Center canBeDismissedByUser:NO]];
    rateView.editable = false;
    [[DSSoundManager sharedManager] addLikeforSongID:object.objectId];
}
#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
   
    [searchBar setShowsCancelButton:YES animated:YES];
    UIView* view=searchBar.subviews[0];
    for (UIView *subView in view.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton *cancelButton = (UIButton*)subView;
            [cancelButton.titleLabel setFont:[UIFont fontWithName:@"FingerPaint-Regular" size:15.0]];
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
