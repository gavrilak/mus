//
//  DSBaseViewController.m
//  music
//
//  Created by Lena on 19.05.15.
//  Copyright (c) 2015 dima. All rights reserved.
//

#import "DSBaseViewController.h"

@interface DSBaseViewController () < BTSimpleSideMenuDelegate>

@end

@implementation DSBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupMenu];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma -mark BTSimpleSideMenuDelegate

-(void)BTSimpleSideMenu:(BTSimpleSideMenu *)menu didSelectItemAtIndex:(NSInteger)index {
    NSLog(@"Item Cliecked : %ld", (long)index);
}

-(void)BTSimpleSideMenu:(BTSimpleSideMenu *)menu selectedItemTitle:(NSString *)title {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Menu Clicked"
                                                   message:[NSString stringWithFormat:@"Item Title : %@", title]
                                                  delegate:self
                                         cancelButtonTitle:@"Dismiss"
                                         otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - Self Methods
- (void) setupMenu {
    
    self.sideMenu.delegate = self;
    
    BTSimpleMenuItem *item1 = [[BTSimpleMenuItem alloc]initWithTitle:@"One"
                                                               image:[UIImage imageNamed:@"icon1.png"]
                                                        onCompletion:^(BOOL success, BTSimpleMenuItem *item) {
                                                            
                                                            NSLog(@"I am Item 1");
                                                        }];
    
    BTSimpleMenuItem *item2 = [[BTSimpleMenuItem alloc]initWithTitle:@"Two"
                                                               image:[UIImage imageNamed:@"icon2.png"]
                                                        onCompletion:^(BOOL success, BTSimpleMenuItem *item) {
                                                            
                                                            NSLog(@"I am Item 2");
                                                        }];
    
    BTSimpleMenuItem *item3 = [[BTSimpleMenuItem alloc]initWithTitle:@"Three"
                                                               image:[UIImage imageNamed:@"icon3.png"]
                                                        onCompletion:^(BOOL success, BTSimpleMenuItem *item) {
                                                            
                                                            NSLog(@"I am Item 3");
                                                        }];
    
    BTSimpleMenuItem *item4 = [[BTSimpleMenuItem alloc]initWithTitle:@"Four"
                                                               image:[UIImage imageNamed:@"icon4.png"]
                                                        onCompletion:^(BOOL success, BTSimpleMenuItem *item) {
                                                            NSLog(@"I am Item 4");
                                                        }];
    
    
    self.sideMenu = [[BTSimpleSideMenu alloc]initWithItem:@[item1, item2, item3, item4]
                                      addToViewController:self];
    
    
    
    
}



@end
