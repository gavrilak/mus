//
//  DsVersionsTableViewController.m
//  music
//
//  Created by Lena on 17.03.15.
//  Copyright (c) 2015 dima. All rights reserved.
//

#import "DSVersionsTableViewController.h"
#import "DSVersionTableViewCell.h"
#import "DSRateView.h"
#import "YRActivityIndicator.h"
#import "NFXIntroViewController.h"
#import "DSSong.h"
#import "UIView+AnimateHidden.h"
#import "GoogleWearAlertObjc.h"

@interface DSVersionsTableViewController ()  <DSRateViewDelegate>
    @property (strong, nonatomic) NSMutableArray* musicObjects;
    @property (assign, nonatomic) NSInteger activeItem;
    @property (assign, nonatomic) NSInteger playItem;
    @property (strong, nonatomic) NSTimer* playTimer;
    @property (assign, nonatomic) NSInteger selectedRow;
    @property (strong , nonatomic) YRActivityIndicator* activityIndicator;
@end

@implementation DSVersionsTableViewController



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"1.jpg"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    
    self.selectedRow = -1;
    self.playItem = -1;
    
    self.activityIndicator = [[YRActivityIndicator alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    self.activityIndicator.center = CGPointMake(self.tableView.center.x, self.tableView.center.y - 80);
    self.activityIndicator.radius = 60;
    self.activityIndicator.maxItems = 5;
    self.activityIndicator.minItemSize = CGSizeMake(10, 10);
    self.activityIndicator.maxItemSize = CGSizeMake(35, 35);
    self.activityIndicator.itemColor = [UIColor colorWithWhite:0.8 alpha:0.8];
    self.musicObjects = [[NSMutableArray alloc] init];
    [self.musicObjects addObject:self.musicObject];
    [self addLoading];
    
    [self loadData];
    [DSSoundManager sharedManager].delegate = self;
    self.playTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];

  
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [DSSoundManager sharedManager].delegate = nil;
    [self.playTimer invalidate];
}

#pragma mark - UITableViewDataSource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
 
   return  [self.musicObjects count];
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *mainTableIdentifier = @"versionCell";
    
    DSVersionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:mainTableIdentifier];
    if (cell == nil) {
        cell = [[DSVersionTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:mainTableIdentifier];
    }
    
    PFObject* object = [self.musicObjects objectAtIndex:indexPath.row];
    cell.artistLabel.text = [object objectForKey:@"author"];
    cell.titleLabel.text = [object objectForKey:@"name"];
    cell.downloadBtn.tag = indexPath.row;
    [cell.downloadBtn addTarget:self action:@selector(downloadClicked:)
               forControlEvents:UIControlEventTouchUpInside];

    
    
    cell.uaprogressBtn.fillOnTouch = YES;
    cell.uaprogressBtn.tintColor = [UIColor purpleColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60.0, 20.0)];
    [label setTextAlignment:NSTextAlignmentCenter];
    label.userInteractionEnabled = NO; // Allows tap to pass through to the progress view.
    cell.uaprogressBtn.centralView = label;
    
    
    cell.uaprogressBtn.progressChangedBlock = ^(UAProgressView *progressView, CGFloat progress) {
        [(UILabel *)progressView.centralView setText:[NSString stringWithFormat:@"%2.0f%%", progress * 100]];
    };
    cell.uaprogressBtn.fillChangedBlock = ^(UAProgressView *progressView, BOOL filled, BOOL animated){
            UIColor *color = (filled ? [UIColor whiteColor] : progressView.tintColor);
            if (animated) {
                [UIView animateWithDuration:0.3 animations:^{
                    [(UILabel *)progressView.centralView setTextColor:color];
                }];
            } else {
                [(UILabel *)progressView.centralView setTextColor:color];
            }
        };
        
      
        
     cell.uaprogressBtn.didSelectBlock = ^(UAProgressView *progressView){
         [self downloadAndPlay:indexPath.row forView:progressView];
      };
    

    return cell;
}


#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    return indexPath;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 60;
}



#pragma mark - Self Methods
- (void) selectRow:(NSIndexPath *) indexPath {
    if (self.selectedRow != indexPath.row) {
        NSIndexPath *myIP = [NSIndexPath indexPathForRow:self.selectedRow inSection:0];
        DSVersionTableViewCell *cell = ( DSVersionTableViewCell*)[self.tableView cellForRowAtIndexPath:myIP];
        if (cell.rateView.hidden == NO){
            [cell.rateView setHiddenAnimated:YES delay:0 duration:0.3];
            [cell.shareBtn setHiddenAnimated:YES delay:0 duration:0.3];
        }
        self.selectedRow = indexPath.row;
        [self.tableView beginUpdates];
        [self animateCell:indexPath andTableView:self.tableView];
        [self.tableView endUpdates];
    }
}
- (void)addLoading{
    
    // [[MSLiveBlur sharedInstance] addSubview:self.activityIndicator];
    //  [MSLiveBlur sharedInstance].isStatic = YES;
    //  [MSLiveBlur sharedInstance].blurRadius = 1.5;
    //  [[MSLiveBlur sharedInstance] blurRect:self.tableView.bounds];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [self.tableView addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
    
}

- (void)removeLoading{
    
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    [self.activityIndicator stopAnimating];
    [self.activityIndicator removeFromSuperview];
    
    //[[MSLiveBlur sharedInstance] stopBlurringRect:self.view.bounds];
    
}

- (void)animateCell:(NSIndexPath*)indexPath andTableView:(UITableView*)tableView
{
    [UIView animateWithDuration:0.5f animations: ^
     {
         DSVersionTableViewCell *cell = ( DSVersionTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
         
         CGRect rect = cell.frame;
         rect.size.height = 125.0f;
         cell.frame = rect;
         
     }];
    DSVersionTableViewCell *cell = ( DSVersionTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    [cell.rateView setHiddenAnimated:NO delay:0 duration:1];
    [cell.shareBtn setHiddenAnimated:NO delay:0 duration:1];
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
        }
    } ];
}
- (void) downloadAndPlay:(NSUInteger) row forView:(UAProgressView*) progressView {
    
    self.activeItem = row;
    PFObject *object = [self.musicObjects objectAtIndex:row];
    PFFile *soundFile = object[@"mfile"];
    [self selectRow:[NSIndexPath indexPathForRow:row inSection:0]];
    
    [soundFile getDataInBackgroundWithBlock:^(NSData *soundData, NSError *error) {
        if(self.playItem!=self.activeItem ) {
            NSIndexPath* activeRow = [NSIndexPath indexPathForRow:self.playItem inSection:0];
            DSVersionTableViewCell* cell =( DSVersionTableViewCell*)  [self.tableView cellForRowAtIndexPath:activeRow];
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


- (void) loadData {
    
        PFQuery *query = [[self.musicObject  relationForKey:@"versions"]  query];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                [self.musicObjects addObjectsFromArray:objects];
                [self reloadData];
                [self removeLoading];
                
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
                [self removeLoading];
            }
        }];
 
}

- (void) reloadData {
    NSMutableArray* newPaths = [NSMutableArray array];
    for (int i =1 ; i < [self.musicObjects count] ; i++) {
        [newPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:newPaths withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    
}


#pragma mark - DSSoundManagerDelegate
- (void) statusChanged:(BOOL) playStatus {
    NSIndexPath* activeRow = [NSIndexPath indexPathForRow:self.playItem inSection:0];
    DSVersionTableViewCell* cell =( DSVersionTableViewCell*)  [self.tableView cellForRowAtIndexPath:activeRow];
    
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
        DSVersionTableViewCell* cell =( DSVersionTableViewCell*)  [self.tableView cellForRowAtIndexPath:activeRow];
        
        [cell.uaprogressBtn setProgress:[DSSoundManager sharedManager].getCurrentProgress];
        
    }
}


@end
