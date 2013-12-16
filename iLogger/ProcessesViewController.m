//
//  FirstViewController.m
//  iLogger
//
//  Created by David Baum on 1/14/13.
//  Copyright (c) 2013 SAMity. All rights reserved.
//

#import "ProcessesViewController.h"
#import "LogsViewController.h"
#import "ProcessesTableViewCell.h"
#import "SystemUtility.h"
#import "Process.h"
#import "MBProgressHUD.h"

@implementation ProcessesViewController

@synthesize processesTableView;
@synthesize tableContents;
@synthesize sortedKeys;
@synthesize adView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Processes", @"Processes");
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            self.tabBarItem.image = [UIImage imageNamed:@"first@2x"];
        } else {
            self.tabBarItem.image = [UIImage imageNamed:@"first"];
        }
    }
    
    return self;
}
							
- (void)viewDidLoad {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.jpg"]];

    self.processesTableView.backgroundView = imageView;
    self.processesTableView.rowHeight = 96.0f;
    [super viewDidLoad];
    
    //[[SystemUtility shareInstance] memoryUsage];
    //[[SystemUtility shareInstance] getCPUInfo];
}

- (void) viewDidAppear:(BOOL)animated {
    [self.adView setHidden:YES];
    [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
    self.adView.frame = CGRectOffset(self.adView.frame, 0, -50);
    [UIView commitAnimations];
    bannerIsVisible = NO;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading processes";
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSArray *processes = [[SystemUtility shareInstance] runningProcesses];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableArray *systemProcesses = [[NSMutableArray alloc] init];
            NSMutableArray *nonSystemProcesses = [[NSMutableArray alloc] init];
            
            for(Process *process in processes) {
                if([process.isSystem boolValue] == YES) {
                    [systemProcesses addObject:process];
                } else {
                    [nonSystemProcesses addObject:process];
                }
            }
            
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            
            self.tableContents = [[NSDictionary alloc]
                                  initWithObjectsAndKeys:[nonSystemProcesses sortedArrayUsingDescriptors:sortDescriptors], @"Non system", [systemProcesses sortedArrayUsingDescriptors:sortDescriptors],
                                  @"System", nil];
            self.sortedKeys = [[self.tableContents allKeys] sortedArrayUsingSelector:@selector(compare:)];
            
            [self.processesTableView reloadData];
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
    
    LogsViewController *logsViewController = [self.tabBarController.viewControllers objectAtIndex:1];
    logsViewController.process = nil;
    
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) loadProcesses {
    NSArray *processes = [[SystemUtility shareInstance] runningProcesses];
    NSMutableArray *systemProcesses = [[NSMutableArray alloc] init];
    NSMutableArray *nonSystemProcesses = [[NSMutableArray alloc] init];
    
    for(Process *process in processes) {
        if([process.isSystem boolValue] == YES) {
            [systemProcesses addObject:process];
        } else {
            [nonSystemProcesses addObject:process];
        }
    }
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    self.tableContents = [[NSDictionary alloc]
                          initWithObjectsAndKeys:[nonSystemProcesses sortedArrayUsingDescriptors:sortDescriptors], @"Non system", [systemProcesses sortedArrayUsingDescriptors:sortDescriptors],
                          @"System", nil];
    self.sortedKeys = [[self.tableContents allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(reloadProcessesTable) userInfo:nil repeats:YES];
}

- (void)reloadProcessesTable {
    [self loadProcesses];
    [self.processesTableView reloadData];
}

#pragma mark action methods
- (void) viewLogs {
    NSArray *listData =[self.tableContents objectForKey:
                        [self.sortedKeys objectAtIndex:[selectedIndexPath section]]];
    NSUInteger row = [selectedIndexPath row];
    Process *process = [listData objectAtIndex:row];
    
    ProcessesTableViewCell *cell = (ProcessesTableViewCell *)[self.processesTableView cellForRowAtIndexPath:selectedIndexPath];
    
    selectedIndexPath = nil;
    
    [self.processesTableView beginUpdates];
    [self.processesTableView endUpdates];
    [cell setSelected:NO animated:YES];
    
    LogsViewController *logsViewController = [self.tabBarController.viewControllers objectAtIndex:1];
    logsViewController.process = process;
    
    self.tabBarController.selectedViewController = logsViewController;
}

#pragma mark Table Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.sortedKeys count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ProcessesTableViewCell *cell = (ProcessesTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];

    [self.processesTableView beginUpdates];
    
    if(selectedIndexPath && selectedIndexPath.row == indexPath.row && selectedIndexPath.section == indexPath.section) {
        selectedIndexPath = nil;
        
        [cell setSelected:NO animated:YES];
        [self.processesTableView deselectRowAtIndexPath:indexPath animated:YES];
    } else if(selectedIndexPath && (selectedIndexPath.row != indexPath.row || selectedIndexPath.section != indexPath.section)){
        cell = (ProcessesTableViewCell *)[tableView cellForRowAtIndexPath:selectedIndexPath];
        [cell setSelected:NO animated:YES];
        
        selectedIndexPath = indexPath;
    } else {
        selectedIndexPath = indexPath;
    }
    
    [self.processesTableView endUpdates];
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    NSArray *listData =[self.tableContents objectForKey:[self.sortedKeys objectAtIndex:section]];
    
    return [listData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"Cell";
    
    NSArray *listData =[self.tableContents objectForKey: [self.sortedKeys objectAtIndex:[indexPath section]]];
    
    ProcessesTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier: simpleTableIdentifier];
    
    if(cell == nil) {
        NSArray* views = nil;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            views = [[NSBundle mainBundle] loadNibNamed:@"ProcessesTableViewCell_iPhone" owner:nil options:nil];
        } else {
            views = [[NSBundle mainBundle] loadNibNamed:@"ProcessesTableViewCell_iPad" owner:nil options:nil];
        }
        
        for (UIView *view in views) {
            if([view isKindOfClass:[UITableViewCell class]]) {
                cell = (ProcessesTableViewCell *)view;
            }
        }
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM d, yyyy, H:mm:ss"];
    
    NSUInteger row = [indexPath row];
    Process *process = [listData objectAtIndex:row];
    
    cell.processNameLabel.text = process.name;
    cell.processPIDLabel.text = process.pid;
    [cell.processPriorityButton setTitle:process.pid forState:UIControlStateNormal];;
    cell.processStartDateLabel.text = [dateFormatter stringFromDate:(NSDate*)process.startDate];
    [cell.processViewLogsButton addTarget:self action:@selector(viewLogs) forControlEvents:UIControlEventTouchUpInside];
    
    if([process.isSystem boolValue]) {
        [cell.processImageView setImage:[UIImage imageNamed:@"system_profiler.png"]];
    } else {
        [cell.processImageView setImage:[UIImage imageNamed:@"iphone_simulator.png"]];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(selectedIndexPath && indexPath.row == selectedIndexPath.row && indexPath.section == selectedIndexPath.section) {
        return 95.0f;
    }
    return 48.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 100)];
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    headerView.opaque = NO;
    headerView.backgroundColor= [UIColor colorWithRed:125.0f/255.0f green:140.0f/255.0f blue:150.0f/255.0f alpha:0.7f];
    
    UILabel *systemTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, -40.0f, headerView.frame.size.width, headerView.frame.size.height)];
    systemTextLabel.text = [self.sortedKeys objectAtIndex:section];
    [systemTextLabel setBackgroundColor:[UIColor clearColor]];
    [systemTextLabel setTextColor:[UIColor whiteColor]];
    
    [headerView addSubview:systemTextLabel];
    
    return headerView;
}

#pragma mark iAd methods
- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    [self.adView setHidden:NO];
    if (!bannerIsVisible) {
        NSTimer *countdownTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self     selector:@selector(advanceTimer:) userInfo:nil repeats:YES];
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addTimer:countdownTimer forMode:NSDefaultRunLoopMode];
        
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        banner.frame = CGRectOffset(banner.frame, 0, 50);
        [UIView commitAnimations];
        bannerIsVisible = YES;
    }
}

- (void)advanceTimer:(NSTimer *)timer {
    if (bannerIsVisible) {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            self.adView.frame = CGRectOffset(self.adView.frame, 0, -65);
        else
            self.adView.frame = CGRectOffset(self.adView.frame, 0, -50);
        [UIView commitAnimations];
        bannerIsVisible = NO;
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    if (bannerIsVisible) {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            banner.frame = CGRectOffset(banner.frame, 0, -65);
        else
            banner.frame = CGRectOffset(banner.frame, 0, -50);
        [UIView commitAnimations];
        bannerIsVisible = NO;
    }
}

@end
