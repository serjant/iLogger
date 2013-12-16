//
//  SystemViewController.m
//  iLogger
//
//  Created by David Baum on 1/20/13.
//  Copyright (c) 2013 SAMity. All rights reserved.
//

#import <sys/sysctl.h>
#import <sys/types.h>
#import <mach/mach.h>
#import <mach/processor_info.h>
#import <mach/mach_host.h>

#import "SystemViewController.h"
#import "SystemUtility.h"
#import "ACMagnifyingView.h"
#import "ACLoupe.h"
#import <AdSupport/AdSupport.h>

@implementation SystemViewController

@synthesize osVersion, model, udid, total, free, progressView, progressValueLabel, macAddress, ipAddress, bootTime, cpuBarGaugeVew, cpuFreq;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"System", @"System");
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            self.tabBarItem.image = [UIImage imageNamed:@"ipad"];
        } else {
            self.tabBarItem.image = [UIImage imageNamed:@"iphone"];
        }
    }
    
    return self;
}

- (void)viewDidLoad {
    ACMagnifyingView *magnifyingView = (ACMagnifyingView *) self.view;
    
    ACLoupe *loupe = [[ACLoupe alloc] init];
	magnifyingView.magnifyingGlass = loupe;
	loupe.scaleAtTouchPoint = NO;
    
    [super viewDidLoad];
}

- (void) viewDidAppear:(BOOL)animated {
    self.progressView.progressTintColor = [UIColor greenColor];
    
    udid.text = [[[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
    model.text = [[UIDevice currentDevice] localizedModel];
    osVersion.text = [NSString stringWithFormat:@"%@ %@", [[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion]];
    macAddress.text = [[SystemUtility shareInstance] getMACAddress];
    ipAddress.text = [[SystemUtility shareInstance] getIPAddress];
        
    float totalFloat = [[[SystemUtility shareInstance] totalDiskSpace] floatValue] / (float)(1024ll * 1024ll * 1024ll);
    float freeFloat = [[[SystemUtility shareInstance] freeDiskSpace] floatValue] / (float)(1024ll * 1024ll * 1024ll);
        
    total.text = [NSString stringWithFormat:@"%.2f GB", totalFloat];
    free.text = [NSString stringWithFormat:@"%.2f GB", freeFloat];
    
    float percent = (100 - freeFloat / (totalFloat / 100)) / 100;
    [self.progressView setProgress:percent];
    [self.progressValueLabel setText:[NSString stringWithFormat:@"%.0f%%", (100 - freeFloat / (totalFloat / 100))]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM d, yyyy, H:mm:ss"];
    
    NSDate *bootDate = [[SystemUtility shareInstance] getBootDate];
    
    if(bootDate != nil)
        [self.bootTime setText:[dateFormatter stringFromDate:bootDate]];
    
    NSString *cpuFrequence = [NSString stringWithFormat:@"%u Mhz", [[SystemUtility shareInstance] cpuFrequenceMhz]];
    [self.cpuFreq setText:cpuFrequence];
    
    [self initCPUMeterView];
    [self readCPUInfo];
    
    [super viewDidAppear:animated];
}

- (void) initCPUMeterView {
    self.cpuBarGaugeVew.numBars = 50;
    self.cpuBarGaugeVew.minLimit = 0.0;
    self.cpuBarGaugeVew.maxLimit = 1;
    self.cpuBarGaugeVew.value = 0.1f;
}

- (void) readCPUInfo {
    int mib[2] = { CTL_HW, HW_NCPU };
    size_t sizeOfNumCPUs = sizeof(numCPUs);
    int status = sysctl(mib, sizeof(mib) / sizeof(int), &numCPUs, &sizeOfNumCPUs, NULL, 0);
    if(status)
        numCPUs = 1;
    
    CPUUsageLock = [[NSLock alloc] init];
    
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                   target:self
                                                 selector:@selector(updateCPUInfo:)
                                                 userInfo:nil
                                                  repeats:YES];
}

- (void)updateCPUInfo:(NSTimer *)timer {
    natural_t numCPUsU = 0U;
    
    kern_return_t err = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &numCPUsU, &cpuInfo, &numCpuInfo);
    if(err == KERN_SUCCESS) {
        [CPUUsageLock lock];
        
        for(unsigned i = 0U; i < numCPUsU; ++i) {
            float inUse, totalCPU;
            if(prevCpuInfo) {
                inUse = (
                         (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER]   - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER])
                         + (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM])
                         + (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE]   - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE])
                         );
                totalCPU = inUse + (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE] - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE]);
            } else {
                inUse = cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER] + cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] + cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE];
                totalCPU = inUse + cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE];
            }
            
            NSLog(@"Core: %u Usage: %f", i, inUse / totalCPU);
            NSLog(@"Total CPU: %f", totalCPU);
            
            [self.cpuBarGaugeVew setValue:inUse / totalCPU];
        }
        [CPUUsageLock unlock];
        
        if(prevCpuInfo) {
            size_t prevCpuInfoSize = sizeof(integer_t) * numPrevCpuInfo;
            vm_deallocate(mach_task_self(), (vm_address_t)prevCpuInfo, prevCpuInfoSize);
        }
        
        prevCpuInfo = cpuInfo;
        numPrevCpuInfo = numCpuInfo;
        
        cpuInfo = NULL;
        numCpuInfo = 0U;
    } else {
        NSLog(@"Error!");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
