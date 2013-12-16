//
//  LogInformation.m
//  iLogger
//
//  Created by David Baum on 1/15/13.
//  Copyright (c) 2013 SAMity. All rights reserved.
//

#import "LogInformation.h"

@implementation LogInformation

@synthesize pid, time, host, sender, facility, readGID, readUID, uid, gid, level, message, ASLMessageID;

- (NSString *) getLogLevelString {
    switch (self.level) {
        case 0:
            return @"Emergency";
            break;
        case 1:
            return @"Alert";
            break;
        case 2:
            return @"Critical";
            break;
        case 3:
            return @"Error";
            break;
        case 4:
            return @"Warning";
            break;
        case 5:
            return @"Notice";
            break;
        case 6:
            return @"Info";
            break;
        case 7:
            return @"Debug";
            break;
        default:
            return @"";
            break;
    }
}

- (UIColor *) getLogLevelColor {
    switch (self.level) {
        case 0:
            return [UIColor yellowColor];
            break;
        case 1:
            return [UIColor yellowColor];
            break;
        case 2:
            return [UIColor redColor];
            break;
        case 3:
            return [UIColor redColor];
            break;
        case 4:
            return [UIColor orangeColor];
            break;
        case 5:
            return [UIColor blueColor];
            break;
        case 6:
            return [UIColor blackColor];
            break;
        case 7:
            return [UIColor brownColor];
            break;
        default:
            return [UIColor blackColor];
            break;
    }
}

@end
