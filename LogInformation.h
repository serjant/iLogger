//
//  LogInformation.h
//  iLogger
//
//  Created by David Baum on 1/15/13.
//  Copyright (c) 2013 SAMity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Process.h"

typedef enum {
    Emergency = 0,
    Alert = 1,
    Critical = 2,
    Error = 3,
    Warning = 4,
    Notice = 5,
    Info = 6,
    Debug = 7
} LOG_LEVELS;

@interface LogInformation : NSObject {
    NSString *pid;
    NSDate *time;
    NSString *host;
    NSString *sender;
    NSString *facility;
    NSString *readUID;
    NSString *uid;
    LOG_LEVELS level;
    NSString *gid;
    NSString *message;
    NSString *readGID;
    NSUInteger *ASLMessageID;
}

@property (nonatomic, strong) NSString *pid;
@property (nonatomic, strong) NSDate *time;
@property (nonatomic, strong) NSString *host;
@property (nonatomic, strong) NSString *sender;
@property (nonatomic, strong) NSString *facility;
@property (nonatomic, strong) NSString *readUID;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, assign) LOG_LEVELS level;
@property (nonatomic, strong) NSString *gid;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *readGID;
@property (nonatomic, assign) NSUInteger *ASLMessageID;

- (NSString *) getLogLevelString;
- (UIColor *) getLogLevelColor;

@end
