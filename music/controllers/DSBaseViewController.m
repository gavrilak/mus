//
//  DSBaseViewController.m
//  music
//
//  Created by Lena on 19.05.15.
//  Copyright (c) 2015 dima. All rights reserved.
//

#import "DSBaseViewController.h"

@interface DSBaseViewController () < RNFrostedSidebarDelegate>

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

#pragma mark - RNFrostedSidebarDelegate

- (void)sidebar:(RNFrostedSidebar *)sidebar didTapItemAtIndex:(NSUInteger)index {
    NSLog(@"Tapped item at index %lu",(unsigned long)index);
    if (index == 3) {
        [sidebar dismissAnimated:YES completion:nil];
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

@end
