//
//  FirstViewController.h
//  iLogger
//
//  Created by David Baum on 1/14/13.
//  Copyright (c) 2013 SAMity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import "Process.h"

@interface ProcessesViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, ADBannerViewDelegate> {
    NSIndexPath *selectedIndexPath;
    BOOL bannerIsVisible;
}

@property (nonatomic, weak) IBOutlet UITableView *processesTableView;
@property (nonatomic, weak) IBOutlet ADBannerView *adView;

@property (nonatomic, strong) NSDictionary *tableContents;
@property (nonatomic, strong) NSArray *sortedKeys;

@end
