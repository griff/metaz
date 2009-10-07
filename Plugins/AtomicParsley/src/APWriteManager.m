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
@synthesize edits;

+ (id)managerWithTask:(NSTask *)task
             delegate:(id<MZDataWriteDelegate>)delegate
                edits:(MetaEdits *)edits
          pictureFile:(NSString *)file
{
    return [[[self alloc] initWithTask:task
                              delegate:delegate
                                 edits:edits                              
                           pictureFile:file] autorelease];
}

- (id)initWithTask:(NSTask *)theTask
          delegate:(id<MZDataWriteDelegate>)theDelegate
             edits:(MetaEdits *)theEdits
       pictureFile:(NSString *)file
{
    self = [super init];
    if(self)
    {
        task = [theTask retain];
        delegate = [theDelegate retain];
        edits = [theEdits retain];
        pictureFile = [file retain];
        NSPipe* out = [NSPipe pipe];
        [task setStandardOutput:out];
    }
    return self;
}

- (void)dealloc
{
    if([task isRunning])
        [task terminate];
    [task release];
    [delegate release];
    [edits release];
    [pictureFile release];
    [super dealloc];
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
    NSLog(@"Starting write %@", [[task arguments] componentsJoinedByString:@" "]);
    [[[task standardOutput] fileHandleForReading] readInBackgroundAndNotify];
    [task launch];
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
    if(status != 0)
        terminated = YES;

    NSFileManager* mgr = [NSFileManager defaultManager];
    NSError* error = nil;
    if(pictureFile)
    {
        if(![mgr removeItemAtPath:pictureFile error:&error])
        {
            NSLog(@"Failed to remove temp picture file %@", [error localizedDescription]);
            error = nil;
        }
    }
    if(terminated)
    {
        if(![mgr removeItemAtPath:[edits savedTempFileName] error:&error])
        {
            NSLog(@"Failed to remove temp write file %@", [error localizedDescription]);
            error = nil;
        }
        if([delegate respondsToSelector:@selector(writeCanceled)])
            [delegate writeCanceled];
    }
    else
    {
        /*
        BOOL isDir = NO;
        if([mgr fileExistsAtPath:[edits savedTempFileName] isDirectory:&isDir] && !isDir)
        {
            if(![mgr removeItemAtPath:[edits loadedFileName] error:&error])
            {
                NSLog(@"Failed to remove loaded file %@", [error localizedDescription]);
                error = nil;
            }
        
            if(![mgr moveItemAtPath:[edits savedTempFileName] toPath:[edits savedFileName] error:&error])
            {
                NSLog(@"Failed to move file to final location %@", [error localizedDescription]);
                error = nil;
            }
        } else if(![[edits loadedFileName] isEqualToString:[edits savedFileName]])
        {
            if(![mgr moveItemAtPath:[edits loadedFileName] toPath:[edits savedFileName] error:&error])
            {
                NSLog(@"Failed to move file to final location %@", [error localizedDescription]);
                error = nil;
            }
        }
        NSString* temp = [[edits loadedFileName] stringByDeletingLastPathComponent];
        NSInteger tag = 0;
        if(![[NSWorkspace sharedWorkspace]
                performFileOperation:NSWorkspaceRecycleOperation
                              source:temp
                         destination:@""
                               files:[NSArray arrayWithObject:[[edits loadedFileName] lastPathComponent]]
                                 tag:&tag])
        {
        
        }
        */
        if([delegate respondsToSelector:@selector(writeFinished)])
            [delegate writeFinished];
    }
}

- (void)handlerGotData:(NSNotification *)note
{
    NSData* data = [[note userInfo]
            objectForKey:NSFileHandleNotificationDataItem];
    NSString* str = [[[NSString alloc]
            initWithData:data
                encoding:NSUTF8StringEncoding] autorelease];
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
