//
//  AppDelegate.m
//  music
//
//  Created by dima on 3/7/15.
//  Copyright (c) 2015 dima. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>

@interface AppDelegate ()

@end

@implementation AppDelegate



+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [Parse setApplicationId:@"Zv6z83uLOMbQytAUSXleLRbklPXvA6SnhnTTz19S"
                  clientKey:@"O2IKg9KUCyK110UdMeJVCAanE01EBREJGC0bYQ4o"];
    
 
    [MagicalRecord setupAutoMigratingCoreDataStack];
    UIImage *backBtnIcon = [UIImage imageNamed:@"back@3x.png"];
    
    [UINavigationBar appearance].backIndicatorImage = backBtnIcon;
    [UINavigationBar appearance].backIndicatorTransitionMaskImage = backBtnIcon;
    //[[UINavigationBar appearance] setBarTintColor: [UIColor colorWithRed:171/255.0 green:0 blue:0 alpha:0.15]];
   [[UINavigationBar appearance] setBackgroundImage:[AppDelegate imageWithColor:[UIColor colorWithRed:171/255.0 green:0 blue:0 alpha:0.55]] forBarMetrics:UIBarMetricsDefault];
   [UINavigationBar appearance].shadowImage = [UIImage new];
  //  [UINavigationBar appearance].opaque = YES;
   // [UINavigationBar appearance].view.backgroundColor = [UIColor clearColor];
    
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                          NSForegroundColorAttributeName:[UIColor whiteColor],
                                                           NSFontAttributeName: [UIFont fontWithName:@"laCartoonerie" size:20.0],
                                                           }];
    
    // set the text color for selected state
  /*  [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,
                                                       [UIFont fontWithName:@"laCartoonerie" size:11.0], NSFontAttributeName,
                                                       nil] forState:UIControlStateSelected];
    // set the text color for unselected state
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,
        [UIFont fontWithName:@"laCartoonerie" size:11.0], NSFontAttributeName,                                               nil] forState:UIControlStateNormal];

    [[UITabBar appearance] setBackgroundImage:[UIImage imageNamed:@"bar.png"]];
    [[UITabBar appearance] setSelectedImageTintColor:[UIColor whiteColor]];
    [UITabBar appearance].clipsToBounds = YES;*/
  
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setDefaultTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:159/255.0 green:0/255.0 blue:0/255.0 alpha:1], NSFontAttributeName: [UIFont fontWithName:@"laCartoonerie" size:16.0]}];
   
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
