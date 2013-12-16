//
//  ProcessesTableViewCell.h
//  iLogger
//
//  Created by David Baum on 1/16/13.
//  Copyright (c) 2013 SAMity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProcessesTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *processImageView;
@property (nonatomic, weak) IBOutlet UILabel *processNameLabel;
@property (nonatomic, weak) IBOutlet UIButton *processPriorityButton;
@property (nonatomic, weak) IBOutlet UILabel *processStartDateLabel;
@property (nonatomic, weak) IBOutlet UILabel *processPIDLabel;
@property (nonatomic, weak) IBOutlet UIButton *processViewLogsButton;
@property (nonatomic, weak) IBOutlet UIImageView *listSubRowImageView;
@property (nonatomic, weak) IBOutlet IBOutlet UILabel *processPidCaptionLabel;
@property (nonatomic, weak) IBOutlet IBOutlet UILabel *processStartDateCaptionLabel;

- (void) setDetailsHidden:(BOOL) isHidden;

@end
