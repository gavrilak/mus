//
//  DSBaseViewController.m
//  music
//
//  Created by Lena on 19.05.15.
//  Copyright (c) 2015 dima. All rights reserved.
//

#import "DSBaseViewController.h"
#import "NFXIntroViewController.h"
#import "DSBaseTableViewCell.h"


@interface DSBaseViewController () < RNFrostedSidebarDelegate , DSSoundManagerDelegate >

@end

@implementation DSBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupMenu];
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"9.png"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    
    UIImage *btnImg = [UIImage imageNamed:@"settings.png"];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0.f, 0.f, btnImg.size.width, btnImg.size.height);
    [btn setImage:btnImg forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = item;
    
    self.activityIndicator = [[YRActivityIndicator alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    self.activityIndicator.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.height/2 - 80);
    self.activityIndicator.radius = 60;
    self.activityIndicator.maxItems = 5;
    self.activityIndicator.minItemSize = CGSizeMake(10, 10);
    self.activityIndicator.maxItemSize = CGSizeMake(35, 35);
    self.activityIndicator.itemColor = [UIColor whiteColor];
    
    [self addLoading];

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
    // Dispose of any resources that can be recreated.
}

- (void)setupMenu {
    NSArray *images = @[
                        [UIImage imageNamed:@"home"],
                        [UIImage imageNamed:@"instruction"],
                        [UIImage imageNamed:@"letter"],
                        [UIImage imageNamed:@"like"]
                        ];
    self.sideMenu = [[RNFrostedSidebar alloc] initWithImages:images];
    self.sideMenu.delegate = self;
    self.sideMenu.showFromRight = YES;
    self.sideMenu.tintColor = [UIColor colorWithRed:159/255.0 green:0 blue:0 alpha:0.4];
    self.sideMenu.itemBackgroundColor = [UIColor colorWithWhite:1 alpha:1];
}

#pragma mark - self Methods

- (void) setRate:(float) rating  forObject: (PFObject*) object  {
    double newRate = ([[object objectForKey:@"rate"] floatValue] * [[object objectForKey:@"colRates"] integerValue] + rating) / ([[object objectForKey:@"colRates"] integerValue] + 1);
    newRate = newRate - [[object objectForKey:@"rate"] floatValue] ;
    [object incrementKey:@"colRates"];
    [object incrementKey:@"rate" byAmount:[NSNumber numberWithDouble:newRate] ];
    [object saveInBackground];
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


- (void) showMenu{
    
    [self.sideMenu show];
    
}
- (void) showInstruction {
    
    [self.sideMenu dismiss];

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

- (void) shareClicked:(id) sender {
    UIImage *sendImage = [UIImage new];
    UIButton* btn = sender;
    PFObject* obj = [self.musicObjects objectAtIndex:btn.tag];
    CGRect rect;
    rect = self.view.bounds;
    rect.size.height = rect.size.height+200.f;
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    dispatch_queue_t queue = dispatch_queue_create("openActivityIndicatorQueue", NULL);
    // send initialization of UIActivityViewController in background
    dispatch_async(queue, ^{
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc]
                                                            initWithActivityItems:@[[NSString stringWithFormat:@"Лучшие рингтоны! Скачай %@ - %@ на свой телефон! itunes.apple.com/ru/artist/bestapp-studio-ltd./id739061892?l=ru",[obj objectForKey:@"author"], [obj objectForKey:@"name"]], sendImage] applicationActivities:nil];
        activityViewController.excludedActivityTypes=@[UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact,UIActivityTypePostToWeibo,UIActivityTypePrint,UIActivityTypeSaveToCameraRoll];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            [self presentViewController:activityViewController animated:YES completion:nil];
            
        });
    });

    
    
    
}


- (void) downloadClicked:(id)sender {
    
    UIButton* btn = sender;
    PFObject *object = [self.musicObjects objectAtIndex:btn.tag];
    if ([object isKindOfClass:[PFObject class]] ) {
        if (![[DSSoundManager sharedManager] existsSongInDownloads:object.objectId]) {
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
    }
}

- (void) changeDownloadIcon:(NSInteger) row {
    
    [UIView animateWithDuration:0.5f animations: ^
     {
         NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:0];
         DSBaseTableViewCell *cell = ( DSBaseTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
         
         [cell.downloadBtn setImage:[UIImage imageNamed:@"complete@3x.png"] forState: UIControlStateNormal];
         
     }];
}

#pragma mark - RNFrostedSidebarDelegate

- (void)sidebar:(RNFrostedSidebar *)sidebar didTapItemAtIndex:(NSUInteger)index {
    NSLog(@"Tapped item at index %lu",(unsigned long)index);
    switch (index) {
        case 0 :
             [sidebar dismissAnimated:YES completion:nil];
            break;
        case 1 :
            [self showInstruction];
            break;
        default:
            break;
    }
    
}

- (void)sidebar:(RNFrostedSidebar *)sidebar didEnable:(BOOL)itemEnabled itemAtIndex:(NSUInteger)index {
    if (itemEnabled) {
      //  [self.optionIndices addIndex:index];
    }
    else {
      //  [self.optionIndices removeIndex:index];
    }
}

#pragma mark - DSRateViewDelegate

- (void)rateView:(DSRateView *)rateView ratingDidChange:(float)rating{
    
    
    if ([[self.musicObjects objectAtIndex:rateView.tag] isKindOfClass:[PFObject class]]){
        PFObject* object = [self.musicObjects objectAtIndex:rateView.tag];
        [self setRate:rating forObject:object];
        [[DSSoundManager sharedManager] addLikeforSongID:object.objectId];
    } else {
        DSSong* song = [self.musicObjects objectAtIndex:rateView.tag];
        PFQuery *query = [PFQuery queryWithClassName:@"Music"];
        [query whereKey:@"objectId" equalTo:song.idSong];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if ([objects count]> 0) {
                PFObject* object = [objects objectAtIndex:0] ;
                [self setRate:rating forObject: object];
                [[DSSoundManager sharedManager] addLikeforSongID:object.objectId];
            }
        }];
    }
    
    UIImage *image;
    if (rating < 2) {
        image = [UIImage imageNamed:@"sad_heart.png"];
    } else if (rating < 4) {
        image = [UIImage imageNamed:@"neutral_heart.png"];
    } else {
        image = [UIImage imageNamed:@"smile_heart.png"];
    }
    [[GoogleWearAlertObjc getInstance]prepareNotificationToBeShown:[[GoogleWearAlertViewObjc alloc]initWithTitle:nil andImage:image andWithType:Message andWithDuration:2.5 inViewController:self atPostion:Center canBeDismissedByUser:NO]];
    [rateView setNotActiveWithDelay:1.5 duration:1 alhpa: 0.4];
    rateView.editable = false;
    
}

#pragma mark - DSSoundManagerDelegate

- (void) statusChanged:(BOOL) playStatus {
    
    NSIndexPath* activeRow = [NSIndexPath indexPathForRow:self.playItem inSection:0];
    DSBaseTableViewCell* cell = (DSBaseTableViewCell*)  [self.tableView cellForRowAtIndexPath:activeRow];
    
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
        DSBaseTableViewCell* cell =( DSBaseTableViewCell*)  [self.tableView cellForRowAtIndexPath:activeRow];
        
        [cell.uaprogressBtn setProgress:[DSSoundManager sharedManager].getCurrentProgress];
        
    }
}




@end
