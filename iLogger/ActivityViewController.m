//
//  ActivityViewController.m
//  iLogger
//
//  Created by Dmitry Beym on 1/15/13.
//  Copyright (c) 2013 SAMity. All rights reserved.
//
#import "ActivityViewController.h"
#import "SystemUtility.h"
#import "MemoryUsage.h"
#import "BNColor.h"

@interface ActivityViewController ()

@end

@implementation ActivityViewController

@synthesize usedMemLabel, totalMemLabel, freeMemLabel, inactiveMemLabel, wiredMemLabel, navigationBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Activity", @"Activity");
        self.tabBarItem.image = [UIImage imageNamed:@"third"];
        [self.navigationBar setBackgroundImage:[UIImage imageNamed: @"nav_bar.png"]
                       forBarMetrics:UIBarMetricsDefault];
    }
    return self;
}

- (void)viewDidLoad {
    [self updateMemoryUsage];
    [super viewDidLoad];
}

- (void) viewDidAppear:(BOOL)animated {
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(updateMemoryUsage) userInfo:nil repeats:YES];
    
    [super viewDidAppear:animated];
}

- (void) viewDidDisappear:(BOOL)animated {
    [updateTimer invalidate];
    
    [super viewDidDisappear:animated];
}

- (void) updateMemoryUsage {
    MemoryUsage *memoryUsage = [[SystemUtility shareInstance] memoryUsage];
    
    if(chart) {
        [chart removeFromSuperview];
    }
    
    float total = memoryUsage.total;
    float active =  (1.0f / total ) * (float)memoryUsage.active;
    float wired = (1.0f / total ) * (float)memoryUsage.wired;
    float free = (1.0f / total ) * (float)memoryUsage.free;
    float inactive = 1.0f - free - wired - active;
    
    chart = [[BNPieChart alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.height / 1.5, self.view.frame.size.width / 1.5)];
    [chart addSlicePortion:active withName:nil];
    [chart addSlicePortion:free withName:nil];
    [chart addSlicePortion:wired withName:nil];
    [chart addSlicePortion:inactive withName:nil];
    
    chart.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
    
    NSMutableArray *colors = [[NSMutableArray alloc] init];
    [colors addObject:[BNColor colorWithRed:1.0f green:0.0f blue:0.0f]];
    [colors addObject:[BNColor colorWithRed:64.0f/255.0f green:128.0f/255.0f blue:0.0f]];
    [colors addObject:[BNColor colorWithRed:1.0f green:127.0f/255.0f blue:0.0f]];
    [colors addObject:[BNColor colorWithRed:0.0f green:128.0f/255.0f blue:1.0f]];
    
    [chart setColors:colors];
    
    [self.view addSubview:chart];
    chart.center = chart.superview.center;
    
    CGRect frame = chart.frame;
    chart.frame = CGRectMake(frame.origin.x, frame.origin.y - 40.0f, chart.frame.size.width, frame.size.height);
    
    [self.usedMemLabel setText:[NSString stringWithFormat:@"%d MB", memoryUsage.active]];
    [self.wiredMemLabel setText:[NSString stringWithFormat:@"%d MB", memoryUsage.wired]];
    [self.freeMemLabel setText:[NSString stringWithFormat:@"%d MB", memoryUsage.free]];
    [self.inactiveMemLabel setText:[NSString stringWithFormat:@"%d MB", memoryUsage.inactive]];
    [self.totalMemLabel setText:[NSString stringWithFormat:@"%d MB", memoryUsage.total]];
    
    [self.totalMemLabel sizeToFit];
    [self.inactiveMemLabel sizeToFit];
    [self.freeMemLabel sizeToFit];
    [self.usedMemLabel sizeToFit];
    [self.wiredMemLabel sizeToFit];
}
 
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
