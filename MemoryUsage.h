//
//  MemoryUsage.h
//  iLogger
//
//  Created by David Baum on 1/15/13.
//  Copyright (c) 2013 SAMity. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MemoryUsage : NSObject

@property (nonatomic, assign) NSInteger free;
@property (nonatomic, assign) NSInteger total;
@property (nonatomic, assign) NSInteger active;
@property (nonatomic, assign) NSInteger inactive;
@property (nonatomic, assign) NSInteger wired;

@end
