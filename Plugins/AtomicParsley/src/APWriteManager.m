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
    self.executing = NO;
    self.finished = YES;
}

@end


@implementation APWriteOperationsController

+ (id)controllerWithProvider:(AtomicParsleyPlugin *)provider
                    delegate:(id<MZDataWriteDelegate>)delegate
                       edits:(MetaEdits *)edits
{
    return [[[self alloc] initWithProvider:provider delegate:delegate edits:edits] autorelease];
}

- (id)initWithProvider:(AtomicParsleyPlugin *)theProvider
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
    if(self.error || self.cancelled)
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
    self.executing = NO;
    self.finished = YES;
}

- (void)standardOutputGotData:(NSNotification *)note
{
    if(self.finished)
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
