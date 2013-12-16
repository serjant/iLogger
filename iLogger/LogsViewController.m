//
//  SecondViewController.m
//  iLogger
//
//  Created by David Baum on 1/14/13.
//  Copyright (c) 2013 SAMity. All rights reserved.
//

#import "LogsViewController.h"
#import "SystemUtility.h"
#import "LogInformation.h"
#import "CopyableCell.h"

@implementation LogsViewController

@synthesize logsTableView, process;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Logs", @"Logs");
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            self.tabBarItem.image = [UIImage imageNamed:@"second@2x"];
        } else {
            self.tabBarItem.image = [UIImage imageNamed:@"second"];
        }
    }
    return self;
}
							
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void) viewDidDisappear:(BOOL)animated {
    [updateTimer invalidate];
    
    [super viewDidDisappear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
    logInfos = [[NSArray alloc] init];
    
    firstTimeLogsCheck = YES;
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setDay:-1];
    searchLogsDate = [gregorian dateByAddingComponents:offsetComponents toDate: [NSDate date] options:0];
    
    [self updateLogsTable];
    
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(updateLogsTable) userInfo:nil repeats:YES];
    
    [super viewDidAppear:animated];
}

- (void) updateLogsTable {
    if(process) {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            NSArray *newLogs = [[SystemUtility shareInstance] readLogsWithPID:process.pid fromDate:searchLogsDate];
            dispatch_async(dispatch_get_main_queue(), ^{
                logInfos = [logInfos arrayByAddingObjectsFromArray:newLogs];
            
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];
                NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            
                if([logInfos count] > 0)
                    logInfos = [logInfos sortedArrayUsingDescriptors:sortDescriptors];
            
                [self.logsTableView reloadData];
            
                if([logInfos count] == 0 && firstTimeLogsCheck) {
                    UIAlertView *alert = [[UIAlertView alloc]
                                          initWithTitle:@"Message"
                                          message:@"No logs found" delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
                    [alert show];
                }
            
                firstTimeLogsCheck = NO;
                searchLogsDate = [NSDate date];
            });
        });
    } else {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            NSArray *newLogs = [[SystemUtility shareInstance] readLogsFromDate:searchLogsDate];
            dispatch_async(dispatch_get_main_queue(), ^{
                logInfos = [logInfos arrayByAddingObjectsFromArray:newLogs];
                
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];
                NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];

                if([logInfos count] > 0)
                    logInfos = [logInfos sortedArrayUsingDescriptors:sortDescriptors];
                
                [self.logsTableView reloadData];
                
                if([logInfos count] == 0 && firstTimeLogsCheck) {
                    UIAlertView *alert = [[UIAlertView alloc]
                                          initWithTitle:@"Message"
                                          message:@"No logs found" delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
                    [alert show];
                }
                
                firstTimeLogsCheck = NO;
                searchLogsDate = [NSDate date];
            });
        });
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark mail action
- (IBAction) actionEmailComposer:(id)sender {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        
        mailViewController.mailComposeDelegate = self;
        [mailViewController setSubject:@"Your console logs"];
        [mailViewController setMessageBody:@"Your console logs" isHTML:NO];
        
        NSArray *arrayPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
        NSString *docDir = [arrayPaths objectAtIndex:0];
        NSString *path = [docDir stringByAppendingString:@"/logs.txt"];
        
        NSMutableString *logsStr = [[NSMutableString alloc] init];
        NSError *error;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM d, yyyy, H:mm:ss"];
        
        for(LogInformation *logInfo in logInfos) {
            [logsStr appendString:[NSString stringWithFormat:@"%@: %@\n",[dateFormatter stringFromDate:logInfo.time], logInfo.message]];
        }
        
        [logsStr writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];

        NSData *logsData = [NSData dataWithContentsOfFile:path];
        [mailViewController addAttachmentData:logsData mimeType:@"text/plain" fileName:@"logs.txt"];
        
        [self presentModalViewController:mailViewController animated:YES];
    } else {
        NSLog(@"Device is unable to send email in its current state.");
    }
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark Table Methods
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    return [logInfos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"CopyableCell";
    
    CopyableCell *cell = (CopyableCell *)[tableView dequeueReusableCellWithIdentifier: simpleTableIdentifier];
    
    if(cell == nil) {
        cell = [[CopyableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:simpleTableIdentifier];
    }
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    [cell.textLabel setFont:[UIFont fontWithName:@"Arial" size:FONT_SIZE]];
    [cell.detailTextLabel setFont:[UIFont fontWithName:@"Arial" size:FONT_SIZE]];
    cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.detailTextLabel.numberOfLines = 0;
    
    NSUInteger row = [indexPath row];
    LogInformation *logInfo = [logInfos objectAtIndex:row];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:LOG_DATE_FORMAT];
    
    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@: %@",[dateFormatter stringFromDate:logInfo.time], logInfo.message]];
    [cell.textLabel setText:[[logInfo getLogLevelString] uppercaseString]];
    [cell.textLabel setTextColor:[logInfo getLogLevelColor]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath { 
    NSUInteger row = [indexPath row];
    LogInformation *logInfo = [logInfos objectAtIndex:row];
    
    NSString *text = logInfo.message;
    
    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat height = MAX(size.height, 55.0f);
    
    return height + (CELL_CONTENT_MARGIN * 2);
}

#pragma mark -
#pragma mark CopyableCellDelegate Methods
- (void) copyableCell:(CopyableCell *)cell selectCellAtIndexPath:(NSIndexPath *)indexPath {
    [self.logsTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void) copyableCell:(CopyableCell *)cell deselectCellAtIndexPath:(NSIndexPath *)indexPath {
    [self.logsTableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (NSString *) copyableCell:(CopyableCell *)cell dataForCellAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < logInfos.count) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:LOG_DATE_FORMAT];
        
        NSUInteger row = [indexPath row];
        LogInformation *logInfo = [logInfos objectAtIndex:row];
        
        NSString *logMessage = [NSString stringWithFormat:@"%@\n%@: %@", [[logInfo getLogLevelString] uppercaseString], [dateFormatter stringFromDate:logInfo.time], logInfo.message];
        
        return logMessage;
    }
    
    return @"";
}

@end