//
//  ProcessesTableViewCell.h
//  iLogger
//
//  Created by Dmitry Beym on 1/16/13.
//  Copyright (c) 2013 SAMity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProcessesTableViewCell : UITableViewCell {
    IBOutlet UIImageView *processImageView;
    IBOutlet UIImageView *listSubRowImageView;
    IBOutlet UILabel *processNameLabel;
    IBOutlet UIButton *processPriorityButton;
    IBOutlet UILabel *processStartDateLabel;
    IBOutlet UILabel *processPIDLabel;
    IBOutlet UIButton *processViewLogsButton;
    IBOutlet UILabel *processPidCaptionLabel;
    IBOutlet UILabel *processStartDateCaptionLabel;
}

@property (nonatomic, strong) IBOutlet UIImageView *processImageView;
@property (nonatomic, strong) IBOutlet UILabel *processNameLabel;
@property (nonatomic, strong) IBOutlet UIButton *processPriorityButton;
@property (nonatomic, strong) IBOutlet UILabel *processStartDateLabel;
@property (nonatomic, strong) IBOutlet UILabel *processPIDLabel;
@property (nonatomic, strong) IBOutlet UIButton *processViewLogsButton;
@property (nonatomic, strong) IBOutlet UIImageView *listSubRowImageView;
@property (nonatomic, strong) IBOutlet IBOutlet UILabel *processPidCaptionLabel;
@property (nonatomic, strong) IBOutlet IBOutlet UILabel *processStartDateCaptionLabel;

- (void) setDetailsHidden:(BOOL) isHidden;

@end
