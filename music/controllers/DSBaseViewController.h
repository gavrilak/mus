//
//  DSBaseViewController.h
//  music
//
//  Created by Lena on 19.05.15.
//  Copyright (c) 2015 dima. All rights reserved.
//
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <UIKit/UIKit.h>
#import "RNFrostedSidebar.h"
#import "YRActivityIndicator.h"
#import "GoogleWearAlertObjc.h"
#import "DSRateView.h"
#import "DSSong.h"
#import "DSSoundManager.h"
#import "UIView+AnimateHidden.h"

@interface DSBaseViewController : UIViewController

@property (nonatomic, strong) RNFrostedSidebar* sideMenu;
@property (strong, nonatomic) YRActivityIndicator* activityIndicator;
@property (nonatomic , weak ) IBOutlet UITableView* tableView;
@property (strong, nonatomic) NSMutableArray* musicObjects;

- (void) showMenu;
- (void) removeLoading;
- (void) addLoading;
- (void)rateView:(DSRateView *)rateView ratingDidChange:(float)rating;
@end
