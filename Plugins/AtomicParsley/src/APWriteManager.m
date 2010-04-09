//
//  APWriteManager.m
//  MetaZ
//
//  Created by Brian Olsen on 29/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "APWriteManager.h"


@implementation APChapterWriteTask

+ (id)taskWithFileName:(NSString *)fileName chaptersFile:(NSString *)chaptersFile
{
    return [[[self alloc] initWithFileName:fileName chaptersFile:chaptersFile] autorelease];
}

- (id)initWithFileName:(NSString *)fileName chaptersFile:(NSString *)theChaptersFile
{
    self = [super init];
    if(self)
    {
        chaptersFile = [theChaptersFile retain];
        if([chaptersFile length] == 0)
            [self setArguments:[NSArray arrayWithObjects:@"-r", fileName, nil]];
        else
            [self setArguments:[NSArray arrayWithObjects:@"--import", chaptersFile, fileName, nil]];

    }
    return self;
}

- (void)taskTerminatedWithStatus:(int)status
{
    NSError* tempError = nil;
    NSFileManager* mgr = [NSFileManager manager];
    if([chaptersFile length]>0)
    {
        if(![mgr removeItemAtPath:chaptersFile error:&tempError])
        {
            MZLoggerError(@"Failed to remove temp chapters file %@", [tempError localizedDescription]);
            tempError = nil;
        }
    }
    
    [self setErrorFromStatus:status];
    self.isExecuting = NO;
    self.isFinished = YES;
}

@end


@implementation APWriteOperationsController

+ (id)controllerWithProvider:(id<MZDataProvider>)provider
                    delegate:(id<MZDataWriteDelegate>)delegate
                       edits:(MetaEdits *)edits
{
    return [[[self alloc] initWithProvider:provider delegate:delegate edits:edits] autorelease];
}

- (id)initWithProvider:(id<MZDataProvider>)theProvider
              delegate:(id<MZDataWriteDelegate>)theDelegate
                 edits:(MetaEdits *)theEdits
{
    self = [super init];
    if(self)
    {
        provider = [theProvider retain];
        delegate = [theDelegate retain];
        edits = [theEdits retain];
    }
    return self;
}

- (void)operationsFinished
{
    if(self.error)
    {
        if([delegate respondsToSelector:@selector(dataProvider:controller:writeCanceledForEdits:error:)])
            [delegate dataProvider:provider controller:self writeCanceledForEdits:edits error:error];
    }
    else
    {
        if([delegate respondsToSelector:@selector(dataProvider:controller:writeFinishedForEdits:)])
            [delegate dataProvider:provider controller:self writeFinishedForEdits:edits];
    }

    [provider removeWriteManager:self];
}

- (void)notifyPercent:(NSInteger)percent
{
    if([delegate respondsToSelector:@selector(dataProvider:controller:writeFinishedForEdits:percent:)])
        [delegate dataProvider:provider controller:self writeFinishedForEdits:edits percent:percent];
}

@end


@implementation APMainWriteTask

+ (id)taskWithController:(APWriteOperationsController*)controller
             pictureFile:(NSString *)file
{
    return [[[self alloc] initWithController:controller pictureFile:file] autorelease];
}

- (id)initWithController:(APWriteOperationsController*)theController
             pictureFile:(NSString *)file;
{
    self = [super init];
    if(self)
    {
        controller = [theController retain];
        pictureFile = [file retain];
    }
    return self;
}

- (void)taskTerminatedWithStatus:(int)status
{
    NSError* tempError = nil;
    NSFileManager* mgr = [NSFileManager manager];

    if(pictureFile)
    {
        if(![mgr removeItemAtPath:pictureFile error:&tempError])
        {
            MZLoggerError(@"Failed to remove temp picture file %@", [tempError localizedDescription]);
            tempError = nil;
        }
    }
    
    [self setErrorFromStatus:status];
    self.isExecuting = NO;
    self.isFinished = YES;
}

- (void)standardOutputGotData:(NSNotification *)note
{
    if(self.isFinished)
        return;
    NSData* data = [[note userInfo]
            objectForKey:NSFileHandleNotificationDataItem];
    NSString* str = [[[NSString alloc]
            initWithData:data
                encoding:NSUTF8StringEncoding] autorelease];
    NSString* origStr = str;
    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([str hasPrefix:@"Started writing to temp file."])
        str = [str substringFromIndex:29];
    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSInteger percent = [str integerValue];
    MZLoggerDebug(@"Got data: %d '%@'", percent, origStr);
    if(percent > 0)
        [controller notifyPercent:percent];
        
    if([task isRunning])
    {
        [[[task standardOutput] fileHandleForReading]
            readInBackgroundAndNotify];
    }
}

@end

/*
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
    [err release];
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
    err = [[NSPipe alloc] init];
    [task setStandardError:err];
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

- (void)cancel
{
    [super cancel];
    if([task isRunning])
        [task terminate];
}

- (void)taskTerminated:(NSNotification *)note
{
    [APDataProvider logFromProgram:@"AtomicParsley" pipe:err];
    NSError* error = nil;
    NSError* tempError = nil;
    
    int status = [task terminationStatus];
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

    NSFileManager* mgr = [NSFileManager manager];
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
        if(chaptersFile && [chaptersFile length]>0)
        {
            if(![mgr removeItemAtPath:chaptersFile error:&tempError])
            {
                MZLoggerError(@"Failed to remove temp chapters file %@", [tempError localizedDescription]);
                tempError = nil;
            }
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

        // Sometimes when writing to a network drive the file is left in a state
        // (I think it is a cache flush issue) so that a subsequent chapter write
        // breaks the file. I hope (have not encountered the issue in a long time)
        // that this extra chapter read at least detects the issue.
        status = [APDataProvider testReadFile:fileName];

        if(chaptersFile && status == 0)
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
    NSString* origStr = str;
    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([str hasPrefix:@"Started writing to temp file."])
        str = [str substringFromIndex:29];
    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSInteger percent = [str integerValue];
    MZLoggerDebug(@"Got data: %d '%@'", percent, origStr);
    if(percent > 0 && [delegate respondsToSelector:@selector(dataProvider:controller:writeFinishedForEdits:percent:)])
        [delegate dataProvider:provider controller:self writeFinishedForEdits:edits percent:percent];
        
    if([task isRunning])
    {
        [[[task standardOutput] fileHandleForReading]
            readInBackgroundAndNotify];
    }
}

@end
*/