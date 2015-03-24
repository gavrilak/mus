//
//  ViewController.m
//  music
//
//  Created by dima on 3/7/15.
//  Copyright (c) 2015 dima. All rights reserved.
//

#import "DSVersionsTableViewController.h"
#import "DSMainViewController.h"
#import "DSMainTableViewCell.h"


@interface DSMainViewController ()

@property (strong, nonatomic) PFRelation* relation;
@property (strong, nonatomic) NSArray* musicObjects;

@end

@implementation DSMainViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"bg.jpg"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:image];

    [self loadDataForSortType:@"top"];
}
  

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark - UITableViewDataSource


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return  [self.musicObjects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *mainTableIdentifier = @"mainCell";
    
   DSMainTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:mainTableIdentifier];
    if (cell == nil) {
        cell = [[DSMainTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:mainTableIdentifier];
    }
    
    PFObject* object = [self.musicObjects objectAtIndex:indexPath.row];
    
    cell.artistLabel.text = [object objectForKey:@"author"];
    cell.titleLabel.text = [object objectForKey:@"name"];
    cell.downloadBtn.tag = indexPath.row;
    [cell.downloadBtn addTarget:self action:@selector(downloadClicked:)
               forControlEvents:UIControlEventTouchUpInside];
    
    
    
    cell.uaprogressBtn.fillOnTouch = YES;
    cell.uaprogressBtn.tintColor = [UIColor purpleColor];
    cell.uaprogressBtn.borderWidth = 2.0;
     cell.uaprogressBtn.lineWidth = 2.0;
    
    UIImageView *triangle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 35)];
   
    [triangle setImage:[UIImage imageNamed:@"triangle.png"]  ];
    
 
    cell.uaprogressBtn.centralView = triangle;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 48.0, 18.0)];
    label.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:14];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = cell.uaprogressBtn.tintColor;
    label.backgroundColor = [UIColor clearColor];



    cell.uaprogressBtn.progressChangedBlock = ^(UAProgressView *progressView, CGFloat progress) {

        [(UILabel *)progressView.centralView setText:[NSString stringWithFormat:@"%2.0f%%", progress * 100]];
    };
    
    cell.uaprogressBtn.fillChangedBlock = ^(UAProgressView *progressView, BOOL filled, BOOL animated){
        UIColor *color = (filled ? [UIColor greenColor] : progressView.tintColor);
        progressView.centralView =label;
            if (animated) {
                [UIView animateWithDuration:0.3 animations:^{
                    [(UILabel *)progressView.centralView setTextColor:color];
                }];
            } else {
                [(UILabel *)progressView.centralView setTextColor:color];
            }
        
    };
    
    
    
    
    cell.uaprogressBtn.didSelectBlock = ^(UAProgressView *progressView){
        
        [self downloadAndPlay:indexPath.row forView:progressView];
        
    };
    
    cell.downloadBtn.hidden = YES;
    
    return cell;
}


#pragma marm - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   
    DSVersionsTableViewController* vc = [segue destinationViewController];
    vc.childrens = self.relation;
   
}

#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    PFObject *object = [self.musicObjects objectAtIndex:indexPath.row];
    self.relation = [object relationForKey:@"versions"];
    return indexPath;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 80;
}



#pragma mark - Self Methods

- (void) downloadClicked:(id)sender {
    
    UIButton* btn = sender;
    PFObject *object = [self.musicObjects objectAtIndex:btn.tag];
    PFFile *soundFile = object[@"mfile"];
    [soundFile getDataInBackgroundWithBlock:^(NSData *soundData, NSError *error) {
        if (!error) {
            NSLog(@"%@",soundFile.name);
        }
    }
    progressBlock:^(int percentDone) {
        
        NSLog(@"%d", percentDone);
        
    }];
}

- (void) downloadAndPlay:(NSUInteger) row forView:(UAProgressView*) progressView {
    
    
    PFObject *object = [self.musicObjects objectAtIndex:row];
    PFFile *soundFile = object[@"mfile"];
    [soundFile getDataInBackgroundWithBlock:^(NSData *soundData, NSError *error) {
        if (!error) {
            
        }
    }
    progressBlock:^(int percentDone) {
        dispatch_async(dispatch_get_main_queue(), ^{
                                   
                    [progressView setProgress: (float) percentDone/100];
        });
    }];
}


- (void) loadDataForSortType:(NSString*) key{
    
    PFQuery *query = [PFQuery queryWithClassName:@"Music"];
    if ([key isEqualToString:@"top"]){
        [query orderByDescending:@"rate"];
    }
    if ([key isEqualToString:@"new"]){
        [query orderByAscending:@"cratedAt"];
        
    }
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            self.musicObjects = objects;
        
            [self.tableView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

#pragma mark - UITabBarDelegate
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    
    switch (tabBar.selectedItem.tag) {
            
        case 0:{
            [self loadDataForSortType:@"top"];
            break;
        }
         
        case 1:{
            [self loadDataForSortType:@"new"];
            break;
        }
            
        case 2:{
            
            break;
        }
            
        case 3:{
            
            break;
        }
        
        
    }
    
}

@end
