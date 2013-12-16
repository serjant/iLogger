//
//  ActivityViewController.h
//  iLogger
//
//  Created by David Baum on 1/15/13.
//  Copyright (c) 2013 SAMity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BNPieChart.h"

@interface ActivityViewController : UIViewController {
    BNPieChart *chart;
    NSTimer *updateTimer;
}

@property (nonatomic, weak) IBOutlet UILabel *freeMemLabel;
@property (nonatomic, weak) IBOutlet UILabel *usedMemLabel;
@property (nonatomic, weak) IBOutlet UILabel *inactiveMemLabel;
@property (nonatomic, weak) IBOutlet UILabel *wiredMemLabel;
@property (nonatomic, weak) IBOutlet UILabel *totalMemLabel;
@property (nonatomic, weak) IBOutlet UINavigationBar *navigationBar;

@end
