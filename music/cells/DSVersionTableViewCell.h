//
//  DSVersionTableViewCell.h
//  music
//
//  Created by Dima on 17.03.15.
//  Copyright (c) 2015 dima. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSBaseTableViewCell.h"
#import "VBFDownloadButton.h"

@interface DSVersionTableViewCell : DSBaseTableViewCell


@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (weak, nonatomic) IBOutlet VBFDownloadButton* vbfButton;


@end
