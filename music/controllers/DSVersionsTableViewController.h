//
//  DsVersionsTableViewController.h
//  music
//
//  Created by Lena on 17.03.15.
//  Copyright (c) 2015 dima. All rights reserved.
//
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <UIKit/UIKit.h>
#import "DSSoundManager.h"

@interface DSVersionsTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITabBarDelegate, DSSoundManagerDelegate>

@property (strong, nonatomic) PFRelation* childrens;

@end
