//
//  MZLogger.m
//  MetaZ
//
//  Created by Brian Olsen on 24/12/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "MZLogger.h"
#import <pthread.h>

@implementation MZNSLogWriter

+ (id)logWriter
{
    return [[[self alloc] init] autorelease];
}

- (void)logMessage:(NSString *)msg level:(GTMLoggerLevel)level
{
    NSLog(@"%@", msg);
}

@end


@implementation MZLogStandardFormatter

- (NSString *)stringForFunc:(NSString *)func
                 withFormat:(NSString *)fmt
                     valist:(va_list)args 
                      level:(GTMLoggerLevel)level {
  return [NSString stringWithFormat:@"[lvl=%d] %@ %@",
          level, (func ? func : @"(no func)"),
          [super stringForFunc:func withFormat:fmt valist:args level:level]];
}

@end  // MZLogStandardFormatter