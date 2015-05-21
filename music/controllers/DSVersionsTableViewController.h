//
//  DsVersionsTableViewController.h
//  music
//
//  Created by Lena on 17.03.15.
//  Copyright (c) 2015 dima. All rights reserved.
//


#import "DSBaseViewController.h"

@interface DSVersionsTableViewController : DSBaseViewController <UITableViewDelegate, UITableViewDataSource, UITabBarDelegate, DSSoundManagerDelegate>

@property (strong, nonatomic) PFObject* musicObject;


@end
