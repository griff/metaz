//
//  MZWriteQueueStatus.m
//  MetaZ
//
//  Created by Brian Olsen on 29/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "MZWriteQueueStatus.h"
#import "MZWriteQueue.h"

@interface MZWriteQueue (Private)

- (void)startNextItem;

@end


@implementation MZWriteQueueStatus
@synthesize edits;
@synthesize percent;
@synthesize writing;
@synthesize controller;
@synthesize completed;

+ (id)statusWithEdits:(MetaEdits *)edits
{
    return [[[self alloc] initWithEdits:edits] autorelease];
}

- (id)initWithEdits:(MetaEdits *)theEdits
{
    self = [super init];
    if(self)
    {
        edits = [theEdits queueCopy];
    }
    return self;
}

- (void)dealloc
{
    [edits release];
    [controller release];
    [super dealloc];
}

- (void)startWriting
{
    if(percent!=0)
    {
        [self willChangeValueForKey:@"percent"];
        percent = 0;
        [self didChangeValueForKey:@"percent"];
    }
    [self willChangeValueForKey:@"writing"];
    controller = [[[edits owner] saveChanges:edits delegate:self] retain];
    writing = 1;
    [self didChangeValueForKey:@"writing"];
}

- (void)stopWriting
{
    if(controller && [controller isRunning])
        [controller terminate];
}

- (void)writeCanceled
{
    [self willChangeValueForKey:@"writing"];
    writing = 0;
    [self didChangeValueForKey:@"writing"];
    [[MZWriteQueue sharedQueue] stop];
}

- (void)writeFinishedPercent:(int)newPercent
{
    [self willChangeValueForKey:@"percent"];
    percent = newPercent;
    [self didChangeValueForKey:@"percent"];
}

- (void)writeFinished
{
    [self willChangeValueForKey:@"writing"];
    writing = 0;
    [self didChangeValueForKey:@"writing"];
    [self willChangeValueForKey:@"completed"];
    completed = YES;
    [self didChangeValueForKey:@"completed"];
    [[MZWriteQueue sharedQueue] startNextItem];
}


@end
