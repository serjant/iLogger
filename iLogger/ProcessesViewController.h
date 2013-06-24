//
//  FirstViewController.h
//  iLogger
//
//  Created by Dmitry Beym on 1/14/13.
//  Copyright (c) 2013 SAMity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import "Process.h"

@interface ProcessesViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, ADBannerViewDelegate> {
    IBOutlet UITableView *processesTableView;
    IBOutlet ADBannerView *adView;
    
    NSDictionary *tableContents;
    NSArray *sortedKeys;
    NSIndexPath *selectedIndexPath;
    BOOL bannerIsVisible;
}

@property (nonatomic, strong) IBOutlet UITableView *processesTableView;
@property (nonatomic, strong) IBOutlet ADBannerView *adView;
@property (nonatomic, strong) NSDictionary *tableContents;
@property (nonatomic, strong) NSArray *sortedKeys;

@end
