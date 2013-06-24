//
//  ActivityViewController.h
//  iLogger
//
//  Created by Dmitry Beym on 1/15/13.
//  Copyright (c) 2013 SAMity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BNPieChart.h"

@interface ActivityViewController : UIViewController {
    IBOutlet UILabel *freeMemLabel;
    IBOutlet UILabel *usedMemLabel;
    IBOutlet UILabel *inactiveMemLabel;
    IBOutlet UILabel *wiredMemLabel;
    IBOutlet UILabel *totalMemLabel;
    IBOutlet UINavigationBar *navigationBar;
    
    BNPieChart *chart;
    NSTimer *updateTimer;
}

@property (nonatomic, strong) IBOutlet UILabel *freeMemLabel;
@property (nonatomic, strong) IBOutlet UILabel *usedMemLabel;
@property (nonatomic, strong) IBOutlet UILabel *inactiveMemLabel;
@property (nonatomic, strong) IBOutlet UILabel *wiredMemLabel;
@property (nonatomic, strong) IBOutlet UILabel *totalMemLabel;
@property (nonatomic, strong) IBOutlet UINavigationBar *navigationBar;

@end
