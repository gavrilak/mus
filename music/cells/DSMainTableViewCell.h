//
//  DSMainTableViewCell.h
//  music
//
//  Created by Lena on 17.03.15.
//  Copyright (c) 2015 dima. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DSMainTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;

@end
