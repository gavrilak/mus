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

+ (UIImage *)imageFromColor:(UIColor *)color forSize:(CGSize)size withCornerRadius:(CGFloat)radius
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Begin a new image that will be the new image with the rounded corners
    // (here with the size of an UIImageView)
    UIGraphicsBeginImageContext(size);
    
    // Add a clip before drawing anything, in the shape of an rounded rect
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius] addClip];
    // Draw your image
    [image drawInRect:rect];
    
    // Get the image, here setting the UIImageView image
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    // Lets forget about that we were drawing
    UIGraphicsEndImageContext();
    
    return image;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [Parse setApplicationId:@"Zv6z83uLOMbQytAUSXleLRbklPXvA6SnhnTTz19S"
                  clientKey:@"O2IKg9KUCyK110UdMeJVCAanE01EBREJGC0bYQ4o"];
    
 
    [MagicalRecord setupAutoMigratingCoreDataStack];
    UIImage *backBtnIcon = [UIImage imageNamed:@"button_back@3x.png"];
    
    [UINavigationBar appearance].backIndicatorImage = backBtnIcon;
    [UINavigationBar appearance].backIndicatorTransitionMaskImage = backBtnIcon;
    
    // set the text color for selected state
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    // set the text color for unselected state
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
 //   [[UITabBar appearance] setSelectionIndicatorImage:[AppDelegate imageFromColor:[UIColor colorWithRed:64/255.0 green:195/255.0 blue:213/255.0 alpha:1] forSize:CGSizeMake(60, 45) withCornerRadius:0]];
    // set the selected icon color

    NSString *tabBarImage = @"tabBar_bg@2x.png";
    UIImage *tabBackground = [[UIImage imageNamed:tabBarImage] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
   // [[UITabBar appearance] setBackgroundImage:tabBackground];
    [[UITabBar appearance] setTintColor:[UIColor redColor]];
     [[UITabBar appearance] setSelectedImageTintColor:[UIColor whiteColor]];
   // [[UITabBar appearance] setSelectedImageTintColor:[UIColor colorWithRed:0/255.0 green:153/255.0 blue:169/255.0 alpha:1]];
   // [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"background.png"]];

  //  UITabBarItem* item = [[UITabBarItem alloc] initWithTitle:@"Categories" image: [UIImage imageNamed:@"top@3x.png"] selectedImage:[UIImage imageNamed:@"top_s@3x.png"]];
//    UITabBarItem* item2 = [[UITabBarItem alloc] initWithTitle:@"Categories" image: [UIImage imageNamed:@"new@3x.png"] selectedImage:[UIImage imageNamed:@"new_s@3x.png"]];
   
 //  NSArray * items = [[NSArray alloc] initWithObjects:item,item2, nil];
 //   for (UITabBarItem *tbi in items) {
 //       tbi.image = [tbi.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
 //       tbi.selectedImage = [tbi.selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    }
 //  [[UITabBar appearance] setItems:items];
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
