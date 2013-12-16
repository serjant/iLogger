//
//  SystemViewController.h
//  iLogger
//
//  Created by David Baum on 1/20/13.
//  Copyright (c) 2013 SAMity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <mach/processor_info.h>
#import "YLProgressBar.h"
#import "F3BarGauge.h"

@interface SystemViewController : UIViewController {
    @private
        processor_info_array_t cpuInfo, prevCpuInfo;
        mach_msg_type_number_t numCpuInfo, numPrevCpuInfo;
        unsigned numCPUs;
        NSTimer *updateTimer;
        NSLock *CPUUsageLock;
}

@property (nonatomic, weak) IBOutlet UILabel *udid;
@property (nonatomic, weak) IBOutlet UILabel *osVersion;
@property (nonatomic, weak) IBOutlet UILabel *model;
@property (nonatomic, weak) IBOutlet UILabel *total;
@property (nonatomic, weak) IBOutlet UILabel *free;
@property (nonatomic, weak) IBOutlet YLProgressBar *progressView;
@property (nonatomic, weak) IBOutlet UILabel *progressValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *macAddress;
@property (nonatomic, weak) IBOutlet UILabel *ipAddress;
@property (nonatomic, weak) IBOutlet UILabel *bootTime;
@property (nonatomic, weak) IBOutlet UILabel *cpuFreq;
@property (nonatomic, weak) IBOutlet F3BarGauge *cpuBarGaugeVew;

@end
