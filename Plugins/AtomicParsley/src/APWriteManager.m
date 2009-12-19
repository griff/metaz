//
//  APWriteManager.m
//  MetaZ
//
//  Created by Brian Olsen on 29/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "APWriteManager.h"


@implementation APWriteManager
@synthesize provider;
@synthesize task;
@synthesize delegate;
@synthesize edits;
@synthesize isFinished;

+ (id)managerForProvider:(id<MZDataProvider>)provider
                    task:(NSTask *)task
                delegate:(id<MZDataWriteDelegate>)delegate
                   edits:(MetaEdits *)edits
             pictureFile:(NSString *)file
            chaptersFile:(NSString *)chapterFile
{
    return [[[self alloc] initForProvider:provider
                                     task:task
                                 delegate:delegate
                                    edits:edits                              
                              pictureFile:file
                             chaptersFile:chapterFile] autorelease];
}

- (id)initForProvider:(id<MZDataProvider>)theProvider
                 task:(NSTask *)theTask
             delegate:(id<MZDataWriteDelegate>)theDelegate
                edits:(MetaEdits *)theEdits
          pictureFile:(NSString *)file
         chaptersFile:(NSString *)theChapterFile
{
    self = [super init];
    if(self)
    {
        provider = [theProvider retain];
        task = [theTask retain];
        delegate = [theDelegate retain];
        edits = [theEdits retain];
        pictureFile = [file retain];
        chaptersFile = [theChapterFile retain];
        NSPipe* out = [NSPipe pipe];
        [task setStandardOutput:out];
    }
    return self;
}

- (void)dealloc
{
    if([task isRunning])
        [task terminate];
    [provider release];
    [task release];
    [delegate release];
    [edits release];
    [pictureFile release];
    [super dealloc];
}

- (void)start
{
    if([self isCancelled])
        return;
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
    MZLoggerDebug(@"Starting write %@", [[task arguments] componentsJoinedByString:@" "]);
    [[[task standardOutput] fileHandleForReading] readInBackgroundAndNotify];
    [task launch];
    if([delegate respondsToSelector:@selector(dataProvider:controller:writeStartedForEdits:)])
        [delegate dataProvider:provider controller:self writeStartedForEdits:edits];
}

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isExecuting
{
    return [task isRunning];
}

/*
- (BOOL)isFinished
{
    return self.isFinished;
}
*/

- (void)cancel
{
    [super cancel];
    if([task isRunning])
        [task terminate];
}

- (void)taskTerminated:(NSNotification *)note
{
    NSError* error = nil;
    NSError* tempError = nil;
    
    int status = [[note object] terminationStatus];
    if(status != 0)
    {
        MZLoggerError(@"Terminated bad %d", status);
        NSDictionary* dict = [NSDictionary dictionaryWithObject:
            [NSString stringWithFormat:
                NSLocalizedString(@"AtomicParsley failed with exit code %d", @"Write failed error"),
                status]
            forKey:NSLocalizedDescriptionKey];
        error = [NSError errorWithDomain:@"AtomicParsleyPlugin" code:status userInfo:dict];
    }

    NSFileManager* mgr = [NSFileManager defaultManager];
    if(pictureFile)
    {
        if(![mgr removeItemAtPath:pictureFile error:&tempError])
        {
            MZLoggerError(@"Failed to remove temp picture file %@", [tempError localizedDescription]);
            tempError = nil;
        }
    }
    if([self isCancelled] || error)
    {
        if(chaptersFile)
        {
            if(![mgr removeItemAtPath:chaptersFile error:&tempError])
            {
                MZLoggerError(@"Failed to remove temp chapters file %@", [tempError localizedDescription]);
                tempError = nil;
            }
        }
        if(![mgr removeItemAtPath:[edits savedTempFileName] error:&tempError])
        {
            MZLoggerError(@"Failed to remove temp write file %@", [tempError localizedDescription]);
            tempError = nil;
        }
        if([delegate respondsToSelector:@selector(dataProvider:controller:writeCanceledForEdits:error:)])
            [delegate dataProvider:provider controller:self writeCanceledForEdits:edits error:error];
    }
    else
    {
        NSString* fileName;
        BOOL isDir = NO;
        if([mgr fileExistsAtPath:[edits savedTempFileName] isDirectory:&isDir] && !isDir)
            fileName = [edits savedTempFileName];
        else
            fileName = [edits loadedFileName];

        if(chaptersFile)
        {
            if([chaptersFile isEqualToString:@""])
                status = [APDataProvider removeChaptersFromFile:fileName];
            else
            {
                status = [APDataProvider importChaptersFromFile:chaptersFile toFile:fileName];
                if(![mgr removeItemAtPath:chaptersFile error:&tempError])
                {
                    MZLoggerError(@"Failed to remove temp chapters file %@", [tempError localizedDescription]);
                    tempError = nil;
                }
            }
            if(status != 0)
            {
                NSDictionary* dict = [NSDictionary dictionaryWithObject:
                    [NSString stringWithFormat:
                        NSLocalizedString(@"mp4chaps failed with exit code %d", @"Write failed error"),
                        status]
                    forKey:NSLocalizedDescriptionKey];
                error = [NSError errorWithDomain:@"AtomicParsleyPlugin" code:status userInfo:dict];
            }
        }
        
        if(error)
        {
            if([delegate respondsToSelector:@selector(dataProvider:controller:writeCanceledForEdits:error:)])
                [delegate dataProvider:provider controller:self writeCanceledForEdits:edits error:error];
        }
        else
        {
            self.isFinished = YES;
            if([delegate respondsToSelector:@selector(dataProvider:controller:writeFinishedForEdits:)])
                [delegate dataProvider:provider controller:self writeFinishedForEdits:edits];
        }
    }
    self.isFinished = YES;
    [provider removeWriteManager:self];
}

- (void)handlerGotData:(NSNotification *)note
{
    if(self.isFinished)
        return;
    NSData* data = [[note userInfo]
            objectForKey:NSFileHandleNotificationDataItem];
    NSString* str = [[[NSString alloc]
            initWithData:data
                encoding:NSUTF8StringEncoding] autorelease];
    MZLoggerDebug(@"Got data: '%@'", str);
    NSInteger percent = [str integerValue];
    if(percent > 0 && [delegate respondsToSelector:@selector(dataProvider:controller:writeFinishedForEdits:percent:)])
        [delegate dataProvider:provider controller:self writeFinishedForEdits:edits percent:percent];
        
    if([task isRunning])
    {
        [[[task standardOutput] fileHandleForReading]
            readInBackgroundAndNotify];
    }
}

@end
