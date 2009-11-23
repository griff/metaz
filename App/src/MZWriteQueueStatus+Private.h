/*
 *  MZWriteQueueStatus+Private.h
 *  MetaZ
 *
 *  Created by Brian Olsen on 23/11/09.
 *  Copyright 2009 Maven-Group. All rights reserved.
 *
 */
#import "MZWriteQueueStatus.h"

@interface MZWriteQueueStatus()

@property(readwrite) int percent;
@property(readwrite,copy) NSString* status;
@property(readwrite) int writing;
@property(readwrite) BOOL completed;
@property(readwrite) BOOL hasRun;

- (void)triggerChangeNotification:(int)changes;

@end
