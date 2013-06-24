//
//  SystemUtility.h
//  iLogger
//
//  Created by Dmitry Beym on 1/15/13.
//  Copyright (c) 2013 SAMity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MemoryUsage.h"

@interface SystemUtility : NSObject

+ (SystemUtility *) shareInstance;

- (NSArray *)runningProcesses;
- (NSArray *) readLogsFromDate:(NSDate *) aDate;
- (NSArray *) readLogsWithPID: (NSString *) aPID fromDate:(NSDate *) aDate;
- (MemoryUsage *) memoryUsage;
- (NSString *) getMACAddress;
- (NSString *) getIPAddress;
- (NSNumber *) freeDiskSpace;
- (NSNumber *) totalDiskSpace;
- (NSUInteger) busFrequenceMhz;
- (NSUInteger) cpuFrequenceMhz;
- (NSDate *) getBootDate;

@end
