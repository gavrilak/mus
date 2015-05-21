//
//  ViewController.h
//  music
//
//  Created by dima on 3/7/15.
//  Copyright (c) 2015 dima. All rights reserved.
//

#import "DSBaseViewController.h"

@interface DSMainViewController : DSBaseViewController <UITableViewDelegate, UITableViewDataSource, UITabBarDelegate, DSSoundManagerDelegate>

@property (nonatomic , weak ) IBOutlet UITabBar* tabbar;

@end

