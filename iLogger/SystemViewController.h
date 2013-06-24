//
//  SystemViewController.h
//  iLogger
//
//  Created by Dmitry Beym on 1/20/13.
//  Copyright (c) 2013 SAMity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <mach/processor_info.h>
#import "YLProgressBar.h"
#import "F3BarGauge.h"

@interface SystemViewController : UIViewController {
    IBOutlet UILabel *udid;
    IBOutlet UILabel *osVersion;
    IBOutlet UILabel *model;
    IBOutlet UILabel *total;
    IBOutlet UILabel *free;
    IBOutlet UILabel *progressValueLabel;
    IBOutlet UILabel *macAddress;
    IBOutlet UILabel *ipAddress;
    IBOutlet UILabel *bootTime;
    IBOutlet UILabel *cpuFreq;
    IBOutlet F3BarGauge *cpuBarGaugeVew;
    IBOutlet YLProgressBar *progressView;
    
    @private
        processor_info_array_t cpuInfo, prevCpuInfo;
        mach_msg_type_number_t numCpuInfo, numPrevCpuInfo;
        unsigned numCPUs;
        NSTimer *updateTimer;
        NSLock *CPUUsageLock;
}

@property (nonatomic, strong) IBOutlet UILabel *udid;
@property (nonatomic, strong) IBOutlet UILabel *osVersion;
@property (nonatomic, strong) IBOutlet UILabel *model;
@property (nonatomic, strong) IBOutlet UILabel *total;
@property (nonatomic, strong) IBOutlet UILabel *free;
@property (nonatomic, strong) IBOutlet YLProgressBar *progressView;
@property (nonatomic, strong) IBOutlet UILabel *progressValueLabel;
@property (nonatomic, strong) IBOutlet UILabel *macAddress;
@property (nonatomic, strong) IBOutlet UILabel *ipAddress;
@property (nonatomic, strong) IBOutlet UILabel *bootTime;
@property (nonatomic, strong) IBOutlet UILabel *cpuFreq;
@property (nonatomic, strong) IBOutlet F3BarGauge *cpuBarGaugeVew;

@end
