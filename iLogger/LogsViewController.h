//
//  SecondViewController.h
//  iLogger
//
//  Created by David Baum on 1/14/13.
//  Copyright (c) 2013 SAMity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "CopyableCell.h"
#import "Process.h"

#define FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 15.0f
#define LOG_DATE_FORMAT @"MMM d, yyyy, H:mm:ss"

@interface LogsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, CopyableCellDelegate> {
    NSArray *logInfos;
    BOOL firstTimeLogsCheck;
    NSDate *searchLogsDate;
    
    NSTimer *updateTimer;
}

@property (nonatomic, weak) IBOutlet UITableView *logsTableView;

@property (nonatomic, strong) Process *process;

- (IBAction) actionEmailComposer:(id)sender;

@end
