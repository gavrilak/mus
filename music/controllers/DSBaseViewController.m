//
//  DSBaseViewController.m
//  music
//
//  Created by Lena on 19.05.15.
//  Copyright (c) 2015 dima. All rights reserved.
//

#import "DSBaseViewController.h"
#import "NFXIntroViewController.h"



@interface DSBaseViewController () < RNFrostedSidebarDelegate >

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
    
    UIImage *btnImg = [UIImage imageNamed:@"button_set_up.png"];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupMenu {
    NSArray *images = @[
                        [UIImage imageNamed:@"icon1"],
                        [UIImage imageNamed:@"icon2"],
                        [UIImage imageNamed:@"icon3"],
                        [UIImage imageNamed:@"icon4"]
                        ];
    self.sideMenu = [[RNFrostedSidebar alloc] initWithImages:images];
    self.sideMenu.delegate = self;
    self.sideMenu.showFromRight = YES;
    self.sideMenu.tintColor = [UIColor colorWithRed:159/255.0 green:0 blue:0 alpha:0.5];
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






@end
