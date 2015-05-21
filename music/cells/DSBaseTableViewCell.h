//
//  DSBaseTableViewCell.h
//  music
//
//  Created by Dima Soladtenko on 21.05.15.
//  Copyright (c) 2015 dima. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UAProgressView.h"
#import "DSRateView.h"

@interface DSBaseTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet DSRateView *rateView;
@property (weak, nonatomic) IBOutlet UAProgressView *uaprogressBtn;
@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;
@property (assign, nonatomic) BOOL isPlaying;

@end
