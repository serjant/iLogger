//
//  SystemUtility.m
//  iLogger
//
//  Created by David Baum on 1/15/13.
//  Copyright (c) 2013 SAMity. All rights reserved.
//

#import "SystemUtility.h"
#import "Process.h"
#import "LogInformation.h"
#import "MemoryUsage.h"

#import <dlfcn.h>
#import <sys/sysctl.h>
#import <sys/socket.h>
#import <sys/types.h>
#import <asl.h>
#import <mach/mach.h>
#import <mach/processor_info.h>
#import <mach/mach_host.h>
#import <net/if.h>
#import <net/if_dl.h>
#import <ifaddrs.h>
#import <arpa/inet.h>

@implementation SystemUtility

+ (SystemUtility *) shareInstance {
	static SystemUtility *sharedSingleton = nil;
	
	@synchronized(self) {
		if (!sharedSingleton) {
			sharedSingleton = [[SystemUtility alloc] init];
		}
	}
    
	return sharedSingleton;
}

- (NSArray *)runningProcesses {
    size_t size;
    struct kinfo_proc *processes = NULL;
    int status;
    
    int mib[4] = { CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0 };
    
    status = sysctl(mib, 4, NULL, &size, NULL, 0);
    processes = malloc(size);
    status = sysctl(mib, 4, processes, &size, NULL, 0);
    
    if (status == 0){
        
        if (size % sizeof(struct kinfo_proc) == 0){
            int nprocess = size / sizeof(struct kinfo_proc);
            if (nprocess){
                NSMutableArray * array = [[NSMutableArray alloc] init];
                
                for (int i = nprocess - 1; i >= 0; i--){
                    int ruid = processes[i].kp_eproc.e_pcred.p_ruid;
                            
                    BOOL systemProcess = YES;
                    if (ruid == 501)
                        systemProcess = NO;

                    Process *process = [[Process alloc] init];
                    process.name = [[NSString alloc] initWithFormat:@"%s", processes[i].kp_proc.p_comm];
                    process.pid = [[NSString alloc] initWithFormat:@"%d", processes[i].kp_proc.p_pid];
                    process.isSystem = [NSNumber numberWithBool:systemProcess];
                    process.priority = [[NSString alloc] initWithFormat:@"%d", processes[i].kp_proc.p_priority];
                    process.startDate = [NSDate dateWithTimeIntervalSince1970:processes[i].kp_proc.p_un.__p_starttime.tv_sec];
                   
                    [array addObject:process];
                }
                
                free(processes);
                
                return array;
            }
        }
    }
    
    return nil;
}

- (NSArray *) readLogsFromDate:(NSDate *) aDate {
    NSMutableArray *logsInfoArray = [[NSMutableArray alloc] init];
    
    aslmsg query, message;
    const char *key, *val;
    
    aslmsg msg = asl_new(ASL_TYPE_MSG);
    asl_set(msg, ASL_KEY_READ_UID, "-1");
    asl_log(NULL, msg, ASL_LEVEL_NOTICE, "Hello, world!");
    asl_free(msg);
    
    query = asl_new(ASL_TYPE_QUERY);
    //asl_set_query(query, ASL_KEY_SENDER, "iLogger", ASL_QUERY_OP_SUBSTRING);
    //asl_set_query(query, ASL_KEY_READ_UID, [@"-1" cStringUsingEncoding:NSASCIIStringEncoding], ASL_QUERY_OP_EQUAL);
    if(aDate) {
        NSString *logSince = [NSString stringWithFormat:@"%.0f", [aDate timeIntervalSince1970]];
        asl_set_query(query, ASL_KEY_TIME, [logSince UTF8String], ASL_QUERY_OP_GREATER_EQUAL);
    }
    
    aslresponse response = asl_search(NULL, query);
    while (NULL != (message = aslresponse_next(response))) {
        LogInformation *logInfo = [[LogInformation alloc] init];
        
        for (int i = 0; (NULL != (key = asl_key(message, i))); i++) {
            val = asl_get(message, key);
            if(val) {
                NSString *string = [NSString stringWithUTF8String:val];
                NSString *keyString = [NSString stringWithUTF8String:(char *)key];
                
                if([keyString isEqualToString:@"UID"]) {
                    logInfo.uid = string;
                }
                if([keyString isEqualToString:@"Facility"]) {
                    logInfo.facility = string;
                }
                if([keyString isEqualToString:@"GID"]) {
                    logInfo.gid = string;
                }
                if([keyString isEqualToString:@"Time"]) {
                    logInfo.time = [NSDate dateWithTimeIntervalSince1970:[string integerValue]];
                }
                if([keyString isEqualToString:@"ASLMessageID"]) {
                    logInfo.ASLMessageID = (NSUInteger *)[string integerValue];
                }
                if([keyString isEqualToString:@"Message"]) {
                    logInfo.message = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                }
                if([keyString isEqualToString:@"PID"]) {
                    logInfo.pid = string;
                }
                if([keyString isEqualToString:@"Level"]) {
                    logInfo.level = [string integerValue];
                }
                if([keyString isEqualToString:@"Sender"]) {
                    logInfo.sender = string;
                }
                if([keyString isEqualToString:@"ReadGID"]) {
                    logInfo.readGID = string;
                }
                if([keyString isEqualToString:@"ReadUID"]) {
                    logInfo.readUID = string;
                }
            }
        }
        
        [logsInfoArray addObject:logInfo];
    }
    
    aslresponse_free(response);
    
    return logsInfoArray;
}

- (NSArray *) readLogsWithPID: (NSString *) aPID fromDate:(NSDate *) aDate{
    NSMutableArray *logsInfoArray = [[NSMutableArray alloc] init];
    
    aslmsg query, msg;
    aslresponse response;
    const char *key, *val;
    
    query = asl_new(ASL_TYPE_QUERY);
    
    asl_set_query(query, ASL_KEY_PID, [aPID cStringUsingEncoding:NSASCIIStringEncoding], ASL_QUERY_OP_EQUAL);
    //asl_set(query, ASL_KEY_READ_UID, 501);
    asl_set_query(query, ASL_KEY_READ_UID, [@"-1" cStringUsingEncoding:NSASCIIStringEncoding], ASL_QUERY_OP_EQUAL);
    
    if(aDate) {
        NSString *logSince = [NSString stringWithFormat:@"%.0f", [aDate timeIntervalSince1970]];
        asl_set_query(query, ASL_KEY_TIME, [logSince UTF8String], ASL_QUERY_OP_GREATER_EQUAL);
    }
    
    response = asl_search(NULL, query);
    while (NULL != (msg = aslresponse_next(response))) {
        LogInformation *logInfo = [[LogInformation alloc] init];
        
        for (int i = 0; (NULL != (key = asl_key(msg, i))); i++) {
            val = asl_get(msg, key);
            if(val) {
                NSString *string = [NSString stringWithUTF8String:val];
                NSString *keyString = [NSString stringWithUTF8String:(char *)key];
                
                if([keyString isEqualToString:@"UID"]) {
                    logInfo.uid = string;
                }
                if([keyString isEqualToString:@"Facility"]) {
                    logInfo.facility = string;
                }
                if([keyString isEqualToString:@"GID"]) {
                    logInfo.gid = string;
                }
                if([keyString isEqualToString:@"Time"]) {
                    logInfo.time = [NSDate dateWithTimeIntervalSince1970:[string integerValue]];
                }
                if([keyString isEqualToString:@"ASLMessageID"]) {
                    logInfo.ASLMessageID = (NSUInteger *)[string integerValue];
                }
                if([keyString isEqualToString:@"Message"]) {
                    logInfo.message = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                }
                if([keyString isEqualToString:@"PID"]) {
                    logInfo.pid = string;
                }
                if([keyString isEqualToString:@"Level"]) {
                    logInfo.level = [string integerValue];
                }
                if([keyString isEqualToString:@"Sender"]) {
                    logInfo.sender = string;
                }
                if([keyString isEqualToString:@"ReadGID"]) {
                    logInfo.readGID = string;
                }
                if([keyString isEqualToString:@"ReadUID"]) {
                    logInfo.readUID = string;
                }
            }
        }
        
        [logsInfoArray addObject:logInfo];
    }

    aslresponse_free(response);
    
    return logsInfoArray;
}

- (MemoryUsage *) memoryUsage{
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    
    vm_size_t pagesize;
    
    host_page_size(host_port, &pagesize);
    
    vm_statistics_data_t vm_stat;
    
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS) {
        NSLog(@"Failed to fetch vm statistics");
        return 0;
    }
    
    natural_t mem_active = vm_stat.active_count * pagesize;
    natural_t mem_free = vm_stat.free_count * pagesize;
    natural_t mem_total = (vm_stat.active_count + vm_stat.inactive_count + vm_stat.wire_count + vm_stat.free_count) * pagesize;
    natural_t mem_inactive = vm_stat.inactive_count * pagesize;
    natural_t mem_wired = vm_stat.wire_count * pagesize;
    
    NSLog(@"Memory usage in bytes: used: %u free: %u total: %u inactive: %u wired: %u", mem_active, mem_free, mem_total, mem_inactive, mem_wired);
    
    MemoryUsage *memoryUsage = [[MemoryUsage alloc] init];
    memoryUsage.total = (mem_total / 1024 / 1024);
    memoryUsage.active = (mem_active / 1024 / 1024);
    memoryUsage.free = (mem_free / 1024 / 1024);
    memoryUsage.inactive = (mem_inactive / 1024 / 1024);
    memoryUsage.wired = (mem_wired / 1024 / 1024);
    
    return memoryUsage;
}

- (NSUInteger) getSysInfo: (uint) typeSpecifier {
    size_t size = sizeof(int);
    int results;
    int mib[2] = {CTL_HW, typeSpecifier};
    sysctl(mib, 2, &results, &size, NULL, 0);
    
    return (NSUInteger) results;
}

- (NSUInteger) cpuFrequenceMhz {
    return [self getSysInfo:HW_CPU_FREQ] / (float)1000000;
}

- (NSUInteger) busFrequenceMhz {
    return [self getSysInfo:HW_BUS_FREQ] / (float)1000000;
}

- (NSString *) getMACAddress {
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error name to index is 0 error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error sysctl");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Error: Memory allocation error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error sysctl");
        free(buf);
        
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    
    free(buf);
    
    NSLog(@"Mac Address: %@", outstring);
    
    return outstring;
}

- (NSNumber *) totalDiskSpace {
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    
    return [fattributes objectForKey:NSFileSystemSize];
}

- (NSNumber *) freeDiskSpace {
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    
    return [fattributes objectForKey:NSFileSystemFreeSize];
}

- (NSString *)getIPAddress {
    NSString *address = @"Not connected";
    
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;

    success = getifaddrs(&interfaces);
    
    if (success == 0) {
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }

    freeifaddrs(interfaces);
    
    return address;
}

- (NSDate *) getBootDate {
    int mib[2];
    size_t size;
    struct timeval  bootTime;
    
    mib[0] = CTL_KERN;
    mib[1] = KERN_BOOTTIME;
    
    size = sizeof(bootTime);
    
    if (sysctl(mib, sizeof(mib) / sizeof(int), &bootTime, &size, NULL, 0) != -1) {
        return [NSDate dateWithTimeIntervalSince1970:bootTime.tv_sec];
    }
    
    return nil;
}

@end
