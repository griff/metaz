//
//  APWriteManager.m
//  MetaZ
//
//  Created by Brian Olsen on 29/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "APWriteManager.h"


@implementation APWriteManager
@synthesize task;
@synthesize delegate;

+ (id)managerWithTask:(NSTask *)task
             delegate:(id<MZDataWriteDelegate>)delegate
{
    return [[[self alloc] initWithTask:task delegate:delegate] autorelease];
}

- (id)initWithTask:(NSTask *)theTask
          delegate:(id<MZDataWriteDelegate>)theDelegate
{
    self = [super init];
    if(self)
    {
        task = [theTask retain];
        delegate = [theDelegate retain];
        NSPipe* out = [NSPipe pipe];
        [task setStandardOutput:out];
    }
    return self;
}

- (void)launch
{
    [[NSNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(handlerGotData:)
                   name:NSFileHandleReadCompletionNotification
                 object:[[task standardOutput] fileHandleForReading]];
    [[NSNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(taskTerminated:)
                   name:NSTaskDidTerminateNotification
                 object:task];
    [[[task standardOutput] fileHandleForReading] readInBackgroundAndNotify];
    [task launch];
}

- (void)dealloc
{
    if([task isRunning])
        [task terminate];
    [task release];
    [delegate release];
    [super dealloc];
}

- (BOOL)isRunning
{
    return [task isRunning];
}

- (void)terminate
{
    terminated = YES;
    [task terminate];
}

- (void)taskTerminated:(NSNotification *)note
{
    int status = [[note object] terminationStatus];
    NSLog(@"Terminated status '%d'", status);
    if([delegate respondsToSelector:@selector(writeFinished)])
        [delegate writeFinished];
}

- (void)handlerGotData:(NSNotification *)note
{
    NSData* data = [[note userInfo]
            objectForKey:NSFileHandleNotificationDataItem];
    NSString* str = [[NSString alloc]
            initWithData:data
                encoding:NSUTF8StringEncoding];
    NSLog(@"Got data: '%@'", str);
    NSInteger percent = [str integerValue];
    if(percent > 0 && [delegate respondsToSelector:@selector(writeFinishedPercent:)])
        [delegate writeFinishedPercent:percent];
        
    if([task isRunning])
    {
        [[[task standardOutput] fileHandleForReading]
            readInBackgroundAndNotify];
    }
}

@end
