//
//  ViewController.h
//  music
//
//  Created by dima on 3/7/15.
//  Copyright (c) 2015 dima. All rights reserved.
//

#import "DSBaseViewController.h"
#import "VMTabBar.h"
@interface DSMainViewController : DSBaseViewController <UITableViewDelegate, UITableViewDataSource, UITabBarDelegate >

@property (nonatomic , weak ) IBOutlet VMTabBar* tabbar;

@end

