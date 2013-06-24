//
//  ProcessesTableViewCell.m
//  iLogger
//
//  Created by Dmitry Beym on 1/16/13.
//  Copyright (c) 2013 SAMity. All rights reserved.
//

#import "ProcessesTableViewCell.h"

@implementation ProcessesTableViewCell

@synthesize processImageView, processNameLabel, processPIDLabel, processPriorityButton, processStartDateLabel, processViewLogsButton, listSubRowImageView, processPidCaptionLabel, processStartDateCaptionLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView *cellBackView = [[UIView alloc] initWithFrame:CGRectZero];
        cellBackView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"list_cell_background"]];

        [self setBackgroundView:cellBackView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [self setDetailsHidden:!selected];
    [super setSelected:selected animated:animated];
}

- (void) setDetailsHidden:(BOOL) isHidden {
    [self.listSubRowImageView setHidden:isHidden];
    [self.processPIDLabel setHidden:isHidden];
    [self.processStartDateLabel setHidden:isHidden];
    [self.processViewLogsButton setHidden:isHidden];
    [self.processPidCaptionLabel setHidden:isHidden];
    [self.processStartDateCaptionLabel setHidden:isHidden];
}

@end
