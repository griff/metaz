//
//  MZTaskOperation.m
//  MetaZ
//
//  Created by Brian Olsen on 12/01/10.
//  Copyright 2010 Maven-Group. All rights reserved.
//

#import "MZTaskOperation.h"
#import <MetaZKit/MZLogger.h>

@implementation MZTaskOperation

+ (id)taskOperation
{
    return [[[self alloc] init] autorelease];
}

+ (id)taskOperationWithTask:(NSTask *)task
{
    return [[[self alloc] initWithTask:task] autorelease];
}

- (id)init
{
    self = [super init];
    if(self)
        task = [[NSTask alloc] init];
    return self;
}

- (id)initWithTask:(NSTask *)theTask
{
    self = [super init];
    if(self)
        task = [theTask retain];
    return self;
}

- (void)dealloc
{
    [task release];
    [super dealloc];
}

@synthesize isExecuting;
@synthesize isFinished;

- (void)start
{
    self.isExecuting = YES;
    if([self isCancelled])
    {
        self.isFinished = YES;
        self.isExecuting = NO;
        return;
    }
    [self performSelectorOnMainThread:@selector(startOnMainThread) withObject:nil waitUntilDone:YES];
}

- (void)startOnMainThread
{
    [[NSNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(taskTerminated:)
                   name:NSTaskDidTerminateNotification
                 object:task];
    
    [self setupIO];
    if([[self standardOutput] isKindOfClass:[NSPipe class]])
    {
        [[NSNotificationCenter defaultCenter]
                addObserver:self
                   selector:@selector(standardOutputGotData:)
                       name:NSFileHandleReadCompletionNotification
                     object:[[self standardOutput] fileHandleForReading]];
        [[[self standardOutput] fileHandleForReading] readInBackgroundAndNotify];
    }
    if([[self standardError] isKindOfClass:[NSPipe class]])
    {
        [[NSNotificationCenter defaultCenter]
                addObserver:self
                   selector:@selector(standardErrorGotData:)
                       name:NSFileHandleReadCompletionNotification
                     object:[[self standardError] fileHandleForReading]];
        [[[self standardError] fileHandleForReading] readInBackgroundAndNotify];
    }
    [task launch];
}

- (void)setupIO
{
    [self setStandardError:[NSPipe pipe]];
    [self setStandardOutput:[NSPipe pipe]];
}

- (BOOL)isConcurrent
{
    return YES;
}

- (void)cancel
{
    [super cancel];
    if([self isRunning]) [task terminate];
}


- (void)setLaunchPath:(NSString *)path
{
    [task setLaunchPath:path];
}

- (void)setArguments:(NSArray *)arguments
{
    [task setArguments:arguments];
}

- (void)setEnvironment:(NSDictionary *)dict
{
    [task setEnvironment:dict];
}

- (void)setCurrentDirectoryPath:(NSString *)path
{
    [task setCurrentDirectoryPath:path];
}

// set standard I/O channels; may be either an NSFileHandle or an NSPipe
- (void)setStandardInput:(id)input
{
    [task setStandardInput:input];
}

- (void)setStandardOutput:(id)output
{
    [task setStandardOutput:output];
}

- (void)setStandardError:(id)error
{
    [task setStandardError:error];
}

// get parameters
- (NSString *)launchPath
{
    return [task launchPath];
}

- (NSArray *)arguments
{
    return [task arguments];
}

- (NSDictionary *)environment
{
    return [task environment];
}

- (NSString *)currentDirectoryPath
{
    return [task currentDirectoryPath];
}

// get standard I/O channels; could be either an NSFileHandle or an NSPipe
- (id)standardInput
{
    return [task standardInput];
}

- (id)standardOutput
{
    return [task standardOutput];
}

- (id)standardError
{
    return [task standardError];
}

- (void)interrupt; // Not always possible. Sends SIGINT.
{
    [task interrupt];
}

- (void)terminate; // Not always possible. Sends SIGTERM.
{
    [task terminate];
}

// status
- (int)processIdentifier
{
    return [task processIdentifier];
}

- (BOOL)isRunning
{
    return [task isRunning];
}

- (int)terminationStatus
{
    return [task terminationStatus];
}

- (void)taskTerminated:(NSNotification *)note
{
    self.isExecuting = NO;
    self.isFinished = YES;
}

- (void)standardOutputGotData:(NSNotification *)note
{
    NSData* data = [[note userInfo]
            objectForKey:NSFileHandleNotificationDataItem];
    NSString* str = [[[NSString alloc]
            initWithData:data
                encoding:NSUTF8StringEncoding] autorelease];

    MZLoggerDebug(@"%@ stdout %@", [[task launchPath] lastPathComponent], str);

    if([task isRunning])
    {
        [[[task standardOutput] fileHandleForReading]
            readInBackgroundAndNotify];
    }
}

- (void)standardErrorGotData:(NSNotification *)note
{
    NSData* data = [[note userInfo]
            objectForKey:NSFileHandleNotificationDataItem];
    NSString* str = [[[NSString alloc]
            initWithData:data
                encoding:NSUTF8StringEncoding] autorelease];

    MZLoggerDebug(@"%@ stderr %@", [[task launchPath] lastPathComponent], str);

    if([task isRunning])
    {
        [[[task standardError] fileHandleForReading]
            readInBackgroundAndNotify];
    }
}

@end
