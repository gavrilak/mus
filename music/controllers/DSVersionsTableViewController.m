//
//  DsVersionsTableViewController.m
//  music
//
//  Created by Lena on 17.03.15.
//  Copyright (c) 2015 dima. All rights reserved.
//

#import "DSVersionsTableViewController.h"
#import "DSVersionTableViewCell.h"
#import "UIView+AnimateHidden.h"
#import "AppDelegate.h"

@interface DSVersionsTableViewController () < DSRateViewDelegate >


  
@end

@implementation DSVersionsTableViewController



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    
    self.navigationController.navigationBar.topItem.title = @"";
    self.navigationItem.title = @"Versions";
    [self.navigationController.navigationBar setBackgroundImage:[AppDelegate imageWithColor:[UIColor colorWithRed:171/255.0 green:0 blue:0 alpha:0.60]] forBarMetrics:UIBarMetricsDefault];
    
    self.selectedRow = -1;
    self.playItem = -1;
    
   
    self.musicObjects = [[NSMutableArray alloc] init];
    [self.musicObjects addObject:self.musicObject];

    
    [self checkMusicObject];

  
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
   
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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
    if ([object isKindOfClass:[PFObject class]]) {
    
        cell.rateView.rating = [[object objectForKey:@"rate"] floatValue];
      
        if ( [object objectForKey:@"author"]  == nil) {
            cell.artistLabel.text =  [[self.musicObjects objectAtIndex:0] objectForKey:@"author"];
            cell.titleLabel.text =   [[self.musicObjects objectAtIndex:0] objectForKey:@"name"];
        } else {
            cell.artistLabel.text = [object objectForKey:@"author"];
            cell.titleLabel.text = [object objectForKey:@"name"];
        }
        cell.rateView.editable = ![[DSSoundManager sharedManager] existsLikeForSongID:object.objectId];
        if (self.selectedRow != indexPath.row && indexPath.row != 0 ) {
            [cell.rateView setHidden:YES];
            [cell.shareBtn setHidden:YES];
        } else {
            [cell.rateView setHidden:NO];
            [cell.shareBtn setHidden:NO];
        }
        if ([[DSSoundManager sharedManager] existsLikeForSongID:object.objectId]) {
            cell.rateView.alpha = 0.5;
        } else {
            cell.rateView.alpha = 1;
        }
    
        if ([[DSSoundManager sharedManager] existsSongInDownloads:object.objectId]) {
            [cell.downloadBtn setImage:[UIImage imageNamed:@"complete@3x.png"] forState: UIControlStateNormal];
        } else {
            [cell.downloadBtn setImage:[UIImage imageNamed:@"download@3x.png"] forState: UIControlStateNormal];
        
        }
    } else {
        DSSong* song = (DSSong*) object;
        cell.rateView.rating = [song.rate floatValue];
        cell.artistLabel.text =  song.author;
        cell.titleLabel.text =  song.name;
        [cell.downloadBtn setImage:[UIImage imageNamed:@"complete@3x.png"] forState: UIControlStateNormal];
        cell.rateView.editable = [[DSSoundManager sharedManager] existsLikeForSongID:song.idSong];
        if (self.selectedRow != indexPath.row && indexPath.row != 0 ) {
            [cell.rateView setHidden:YES];
            [cell.shareBtn setHidden:YES];
        } else {
            [cell.rateView setHidden:NO];
            [cell.shareBtn setHidden:NO];
        }
        if ([[DSSoundManager sharedManager] existsLikeForSongID:song.idSong]) {
            cell.rateView.editable = NO;
            cell.rateView.alpha = 0.5;
        } else {
            cell.rateView.editable = YES;
            cell.rateView.alpha = 1;
        }

    }
    
    cell.rateView.delegate = self;
    cell.rateView.tag = indexPath.row;
    cell.rateView.notSelectedImage = [UIImage imageNamed:@"heart_empty@2x.png"];
    cell.rateView.halfSelectedImage =  [UIImage imageNamed:@"heart_half@2x.png"];
    cell.rateView.fullSelectedImage = [UIImage imageNamed:@"heart_full@2x.png"];
    cell.rateView.maxRating = 5;
   
    
    cell.downloadBtn.tag = indexPath.row;
    [cell.downloadBtn addTarget:self action:@selector(downloadClicked:)
               forControlEvents:UIControlEventTouchUpInside];

    cell.shareBtn.tag = indexPath.row;
    [cell.shareBtn addTarget:self action:@selector(shareClicked:)
               forControlEvents:UIControlEventTouchUpInside];
   
    
    cell.uaprogressBtn.tag = indexPath.row;
    cell.uaprogressBtn.fillOnTouch = YES;
    cell.uaprogressBtn.tintColor = [UIColor colorWithWhite:1 alpha:1];
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
    label.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:12];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = cell.uaprogressBtn.tintColor;
    label.backgroundColor = [UIColor clearColor];
    cell.uaprogressBtn.cancelSelectBlock =  ^(UAProgressView *progressView) {
        if (![progressView.centralView isKindOfClass:[UIImageView class]]){
            if ( progressView.tag == self.playItem && [[DSSoundManager sharedManager] isPlaying]) {
                cell.uaprogressBtn.centralView = square;
            } else {
                cell.uaprogressBtn.centralView = triangle;
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


#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self selectRow:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.row == self.selectedRow || indexPath.row == 0){
        return 125.0f;
    }  else {
        return 80;
    }

}




#pragma mark - Self Methods




- (void) selectRow:(NSIndexPath *) indexPath {
    if (self.selectedRow != indexPath.row) {
        NSIndexPath *myIP = [NSIndexPath indexPathForRow:self.selectedRow inSection:0];
        DSVersionTableViewCell *cell = ( DSVersionTableViewCell*)[self.tableView cellForRowAtIndexPath:myIP];
        if (cell.rateView.hidden == NO){
            [cell.rateView setHiddenAnimated:YES editable:cell.rateView.editable delay:0 duration:0.3];
            [cell.shareBtn setHiddenAnimated:YES editable:YES  delay:0 duration:0.3];
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
         DSVersionTableViewCell *cell = ( DSVersionTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
         
         CGRect rect = cell.frame;
         rect.size.height = 125.0f;
         cell.frame = rect;
         
     }];
    DSVersionTableViewCell *cell = ( DSVersionTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    [cell.rateView setHiddenAnimated:NO editable:cell.rateView.editable delay:0 duration:1];
    [cell.shareBtn setHiddenAnimated:NO editable:YES delay:0 duration:1];
}

- (void) downloadAndPlay:(NSUInteger) row forView:(UAProgressView*) progressView {
    
    self.activeItem = row;
    PFObject *object = [self.musicObjects objectAtIndex:row];
    PFFile *soundFile = object[@"mfile"];
    [self selectRow:[NSIndexPath indexPathForRow:row inSection:0]];
    
    [soundFile getDataInBackgroundWithBlock:^(NSData *soundData, NSError *error) {
        if(self.playItem >= 0) {
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

- (void) checkMusicObject {
    if([self.musicObject isKindOfClass:[PFObject class]])  {
        [self loadData];
    } else {
        DSSong* song = (DSSong*) self.musicObject;
        PFQuery *query = [PFQuery queryWithClassName:@"Music"];
        [query whereKey:@"objectId" equalTo:song.idSong];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if ([objects count]> 0) {
                self.musicObject = [objects objectAtIndex:0];
                [self loadData];
            }
        }];
    }
    
}


- (void) loadData {
    
    NSString* ganre = [self.musicObject objectForKey:@"ganre"];
    NSString* author = [self.musicObject objectForKey:@"author" ];
    if (ganre == nil) {
        ganre = @"unknown";
    }
    PFQuery *queryFirst = [[self.musicObject  relationForKey:@"versions"]  query];
    
    PFQuery *queryA = [PFQuery queryWithClassName:@"Music"];
    [queryA whereKey:@"objectId" notEqualTo:self.musicObject.objectId];
    [queryA whereKey:@"author" matchesRegex:author modifiers:@"i" ];
    
    PFQuery *queryB = [PFQuery queryWithClassName:@"Music"];
    [queryB whereKey:@"ganre" equalTo:ganre];
    [queryB whereKey:@"objectId" notEqualTo:self.musicObject.objectId];
    
    PFQuery *querySecond = [PFQuery orQueryWithSubqueries:@[queryA,queryB]];
    NSSortDescriptor* descriptor= [NSSortDescriptor sortDescriptorWithKey:@"author" ascending:YES comparator:^NSComparisonResult(id obj1, id obj2) {
        if( [obj1 isEqualToString:author]) {
            return NSOrderedSame;
        } else {
            return NSOrderedDescending;
        }
            
    }];
    [querySecond orderBySortDescriptor:descriptor];
    [queryFirst findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    if (!error) {
        [self.musicObjects removeAllObjects];
        [self.musicObjects addObject:self.musicObject];
        [self.musicObjects addObjectsFromArray:objects];
        
        [querySecond findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                [self.musicObjects addObjectsFromArray:objects];
                [self reloadData];
                [self removeLoading];
            } else {
                 NSLog(@"Error: %@ %@", error, [error userInfo]);
                [self removeLoading];
            }
        }];
                
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





@end
