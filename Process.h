//
//  Process.h
//  iLogger
//
//  Created by David Baum on 1/15/13.
//  Copyright (c) 2013 SAMity. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Process : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *pid;
@property (nonatomic, strong) NSNumber *isSystem;
@property (nonatomic, strong) NSString *priority;
@property (nonatomic, strong) NSDate *startDate;

@end
