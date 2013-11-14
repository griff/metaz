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

+ (NSSet *)keyPathsForValuesAffectingIsFinished
{
    return [NSSet setWithObjects:@"finished", nil];
}

+ (NSSet *)keyPathsForValuesAffectingIsExecuting
{
    return [NSSet setWithObjects:@"executing", nil];
}

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
    return [self initWithTask:[[[NSTask alloc] init] autorelease]];
}

- (id)initWithTask:(NSTask *)theTask
{
    self = [super init];
    if(self) {
        task = [theTask retain];
        standardErrorReason = YES;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]
            removeObserver:self
                      name:NSTaskDidTerminateNotification
                    object:task];
    [self releaseStandardOutput];
    [self releaseStandardError];
    [task release];
    [super dealloc];
}

@synthesize executing;
@synthesize finished;
@synthesize standardErrorReason;

- (void)start
{
    self.executing = YES;
    [self performSelectorOnMainThread:@selector(startOnMainThread) withObject:nil waitUntilDone:YES];
}

- (void)startOnMainThread
{
    if([self isCancelled])
    {
        [self taskTerminatedWithStatus:0];
        return;
    }
    [[NSNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(taskTerminated:)
                   name:NSTaskDidTerminateNotification
                 object:task];
    
    [self setupStandardInput];
    [self setupStandardOutput];
    [self setupStandardError];
    MZLoggerDebug(@"Launch %@ %@", 
        [[task launchPath] lastPathComponent],
        [[task arguments] componentsJoinedByString:@" "]);
    [task launch];
}

- (void)setupStandardInput
{
    [self setStandardInput:[NSPipe pipe]];
}

- (void)setupStandardOutput
{
    [self setStandardOutput:[NSPipe pipe]];
    [[NSNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(standardOutputGotData:)
                   name:NSFileHandleReadCompletionNotification
                 object:[[self standardOutput] fileHandleForReading]];
    [[[self standardOutput] fileHandleForReading] readInBackgroundAndNotify];
}

- (void)releaseStandardOutput
{
    if([[self standardOutput] isKindOfClass:[NSPipe class]])
    {
        [[NSNotificationCenter defaultCenter]
                removeObserver:self
                          name:NSFileHandleReadCompletionNotification
                        object:[[self standardOutput] fileHandleForReading]];
    }
}

- (void)setupStandardError
{
    [self setStandardError:[NSPipe pipe]];
    if(!self.standardErrorReason)
        [self setupBackgroundStandardError];
}

- (void)setupBackgroundStandardError;
{
    [[NSNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(standardErrorGotData:)
                   name:NSFileHandleReadCompletionNotification
                 object:[[self standardError] fileHandleForReading]];
    [[[self standardError] fileHandleForReading] readInBackgroundAndNotify];
}

- (void)releaseStandardError
{
    if([[self standardError] isKindOfClass:[NSPipe class]])
    {
        [[NSNotificationCenter defaultCenter]
                removeObserver:self
                          name:NSFileHandleReadCompletionNotification
                        object:[[self standardError] fileHandleForReading]];
    }
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

- (void)setStandardError:(id)errorIO
{
    [task setStandardError:errorIO];
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
    [[NSNotificationCenter defaultCenter]
            removeObserver:self
                      name:NSTaskDidTerminateNotification
                    object:task];
    [self taskTerminatedWithStatus:[self terminationStatus]];
}

- (void)taskTerminatedWithStatus:(int)status;
{
    [self setErrorFromStatus:status];
    self.executing = NO;
    self.finished = YES;
}

- (void)setErrorString:(NSString *)err code:(int)status
{
    if(self.standardErrorReason) {
        NSData* data = [[[self standardError] fileHandleForReading] readDataToEndOfFile];
        NSString* errStr = [[[NSString alloc]
                                initWithData:data
                                    encoding:NSUTF8StringEncoding] autorelease];
        errStr = [errStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if([errStr length] > 0)
            err = errStr;
    }

    NSString* program = [[task launchPath] lastPathComponent];
    MZLoggerError(@"%@", err);
    NSDictionary* dict = [NSDictionary dictionaryWithObject:err
                                                     forKey:NSLocalizedDescriptionKey];
    self.error = [NSError errorWithDomain:program code:status userInfo:dict];
}

- (void)setErrorFromStatus:(int)status
{
    if(status != 0)
    {
        NSString* program = [[task launchPath] lastPathComponent];
        [self setErrorString:[NSString stringWithFormat:
                                NSLocalizedString(@"%@ failed with exit code %d", @"Write failed error"),
                                program,
                                status]
                        code:status];
    }
}

- (void)standardOutputGotData:(NSNotification *)note
{
    NSData* data = [[note userInfo]
            objectForKey:NSFileHandleNotificationDataItem];
    NSString* str = [[[NSString alloc]
            initWithData:data
                encoding:NSUTF8StringEncoding] autorelease];

    if([str length] > 0)
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

    if([str length] > 0)
        MZLoggerDebug(@"%@ stderr %@", [[task launchPath] lastPathComponent], str);

    if([task isRunning])
    {
        [[[task standardError] fileHandleForReading]
            readInBackgroundAndNotify];
    }
}

@end


@implementation MZParseTaskOperation

- (void)dealloc
{
    [data release];
    [super dealloc];
}

@synthesize data;
@synthesize terminated;

- (void)parseData
{
}

- (void)taskTerminatedWithStatus:(int)status;
{
    if(status != 0 || [self isCancelled])
    {
        [self setErrorFromStatus:status];
        self.executing = NO;
        self.finished = YES;
        return;
    }

    self.terminated = YES;
    if(self.data)
    {
        [self parseData];
        self.executing = NO;
        self.finished = YES;    
    }
}

- (void)setupStandardOutput
{
    [self setStandardOutput:[NSPipe pipe]];
    [[NSNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(standardOutputGotData:)
                   name:NSFileHandleReadToEndOfFileCompletionNotification
                 object:[[self standardOutput] fileHandleForReading]];
    [[[self standardOutput] fileHandleForReading] readToEndOfFileInBackgroundAndNotify];
}

- (void)releaseStandardOutput
{
    if([[self standardOutput] isKindOfClass:[NSPipe class]])
    {
        [[NSNotificationCenter defaultCenter]
                removeObserver:self
                          name:NSFileHandleReadToEndOfFileCompletionNotification
                        object:[[self standardOutput] fileHandleForReading]];
    }
}

- (void)standardOutputGotData:(NSNotification *)note
{
    if(self.finished || [self isCancelled])
        return;
    self.data = [[note userInfo]
            objectForKey:NSFileHandleNotificationDataItem];
    if(self.terminated)
    {
        [self parseData];
        self.executing = NO;
        self.finished = YES;    
    }
}

@end