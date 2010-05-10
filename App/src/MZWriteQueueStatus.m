//
//  MZWriteQueueStatus.m
//  MetaZ
//
//  Created by Brian Olsen on 29/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "MZWriteQueueStatus.h"
#import "MZWriteQueueStatus+Private.h"
#import "MZWriteQueue.h"
#import "MZWriteQueue+Private.h"
#import "MZMetaLoader.h"

@implementation MZWriteQueueStatus
@synthesize edits;
@synthesize percent;
@synthesize status;
@synthesize writing;
@synthesize controller;
@synthesize completed;
@synthesize hasRun;

+ (id)statusWithEdits:(MetaEdits *)edits
{
    return [[[self alloc] initWithEdits:edits] autorelease];
}

- (id)initWithEdits:(MetaEdits *)theEdits
{
    self = [super init];
    if(self)
    {
        edits = [theEdits retain];
        [edits prepareForQueue];
        status = NSLocalizedString(@"Waiting to start", @"Write queue status text");
    }
    return self;
}

- (void)dealloc
{
    [edits release];
    [controller release];
    [status release];
    [super dealloc];
}

- (void)startWriting
{
    self.status = NSLocalizedString(@"Preparing for write", @"Write queue status text");
    if(percent!=0)
    {
        //[self willChangeValueForKey:@"percent"];
        self.percent = 0;
        //[self didChangeValueForKey:@"percent"];
    }
    //[self willChangeValueForKey:@"writing"];
    controller = [[[MZPluginController sharedInstance] saveChanges:edits delegate:self] retain];
    self.writing = 1;
    //[self didChangeValueForKey:@"writing"];
    if(!controller)
    {
        self.status = [NSString stringWithFormat:
            NSLocalizedString(@"Input file '%@' not found", @"Write input file missing"),
            [[edits loadedFileName] lastPathComponent] ];
        [self finished];
    }
}

- (BOOL)stopWriting
{
    if(controller && ![controller isFinished])
    {
        [controller cancel];
        return YES;
    }
    return NO;
}

- (void)stopWritingAndRemove
{
    if(controller && ![controller isFinished])
    {
        removeOnCancel = YES;
        [controller cancel];
    }
    else
    {
        [[MZMetaLoader sharedLoader] reloadEdits:edits];
        [[MZWriteQueue sharedQueue] removeObjectFromQueueItems:self];
    }
}

- (void)finished
{
    MZWriteQueue* q = [MZWriteQueue sharedQueue];
    self.writing = 0;
    [self triggerChangeNotification:100-self.percent];
    [q willChangeValueForKey:@"completedItems"];
    self.hasRun = YES;
    if(self.completed)
        self.status = NSLocalizedString(@"Completed", @"Write queue status text");
    [q didChangeValueForKey:@"completedItems"];
    [[MZWriteQueue sharedQueue] startNextItem];
}

#pragma mark - MZDataWriteDelegate implementation

- (void)dataProvider:(id<MZDataProvider>)provider 
          controller:(id<MZDataController>)controller
writeStartedForEdits:(MetaEdits *)edits
{
    self.status = [NSString stringWithFormat:
        NSLocalizedString(@"Completed writing %d%%", @"Write queue status text"),
        0];
}


- (void)dataProvider:(id<MZDataProvider>)provider 
          controller:(id<MZDataController>)controller
        writeCanceledForEdits:(MetaEdits *)theEdits
              error:(NSError *)theError
{
    NSFileManager* mgr = [NSFileManager manager];
    BOOL isDir = NO;
    if([mgr fileExistsAtPath:[theEdits savedTempFileName] isDirectory:&isDir] && !isDir)
    {
        NSError *tempError = nil;
        if(![mgr removeItemAtPath:[theEdits savedTempFileName] error:&tempError])
        {
            MZLoggerError(@"Failed to remove temp write file %@", [tempError localizedDescription]);
            tempError = nil;
        }
    }

    //[self willChangeValueForKey:@"writing"];
    self.writing = 0;
    //[self didChangeValueForKey:@"writing"];
    if(!theError)
        self.status = NSLocalizedString(@"Stopped", @"Write queue status text");
    else
    {
        self.status = [theError localizedDescription];
        self.hasRun = YES;
    }

    [self triggerChangeNotification:-self.percent]; // Revert progress
    if(removeOnCancel || theError)
    {
        if(removeOnCancel)
        {
            [[MZMetaLoader sharedLoader] reloadEdits:edits];
            [[MZWriteQueue sharedQueue] removeObjectFromQueueItems:self];
        }
        else
        {
            NSDictionary* userInfo = [NSDictionary dictionaryWithObject:edits forKey:MZMetaEditsNotificationKey];
            [[NSNotificationCenter defaultCenter]
                    postNotificationName:MZQueueItemFailed
                                  object:self
                                userInfo:userInfo];
        }
        if(!removeOnCancel || [[MZWriteQueue sharedQueue] hasNextItem])
            [[MZWriteQueue sharedQueue] startNextItem];
        else
            [[MZWriteQueue sharedQueue] stop];
    }
    else
    {
        MZWriteQueue* q = [MZWriteQueue sharedQueue];
        [q willChangeValueForKey:@"pendingItems"];
        [q willChangeValueForKey:@"completedItems"];
        [q stop];
        [q didChangeValueForKey:@"pendingItems"];
        [q didChangeValueForKey:@"completedItems"];
    }
    [[MZWriteQueue sharedQueue] itemStopped];
}

- (void)dataProvider:(id<MZDataProvider>)provider
          controller:(id<MZDataController>)controller
        writeFinishedForEdits:(MetaEdits *)theEdits percent:(int)newPercent
{
    //[self willChangeValueForKey:@"percent"];
    int diff = newPercent-percent;
    self.percent = newPercent;
    self.status = [NSString stringWithFormat:
        NSLocalizedString(@"Completed writing %d%%", @"Write queue status text"),
        newPercent];
    [self triggerChangeNotification:diff];
    //[self didChangeValueForKey:@"percent"];
}

- (void)dataProvider:(id<MZDataProvider>)provider
          controller:(id<MZDataController>)controller
        writeFinishedForEdits:(MetaEdits *)theEdits
{
    MZWriteQueue* q = [MZWriteQueue sharedQueue];
    NSFileManager* mgr = [NSFileManager manager];
    NSError* error = nil;

    BOOL isDir = NO;
    if([mgr fileExistsAtPath:[edits savedTempFileName] isDirectory:&isDir] && !isDir)
    {
        BOOL putOriginalsInTrash = [[NSUserDefaults standardUserDefaults] boolForKey:@"putOriginalsInTrash"];
        BOOL needsRemoval = !putOriginalsInTrash;
        BOOL shouldKeepOld = YES;
        BOOL shouldMove = YES;
        if(putOriginalsInTrash)
        {
            NSString* temp = [[edits loadedFileName] stringByDeletingLastPathComponent];
            NSInteger tag = 0;
            if(![[NSWorkspace sharedWorkspace]
                    performFileOperation:NSWorkspaceRecycleOperation
                                  source:temp
                             destination:@""
                                   files:[NSArray arrayWithObject:[[edits loadedFileName] lastPathComponent]]
                                     tag:&tag])
            {
                TrashHandling handling = q.removeWhenTrashFailes;
                if(handling == PromptForTrashHandling)
                {
                    BOOL overwrite = [[edits loadedFileName] isEqual:[edits savedFileName]];
                    NSAlert* alert = [[NSAlert alloc] init];
                    NSString* title = [NSString stringWithFormat:
                            NSLocalizedString(@"Unable to put original \"%@\" in trash", @"Trash title"),
                            [[edits loadedFileName] lastPathComponent]];
                    [alert setMessageText:title];
                    [alert addButtonWithTitle:NSLocalizedString(@"Keep", @"Button text for keep action")];
                    if(overwrite)
                    {
                        [alert setInformativeText:NSLocalizedString(@"Do you wish to overwrite it anyway ?", @"Trash removal question")];
                        [alert addButtonWithTitle:NSLocalizedString(@"Overwrite", @"Button text for overwrite action")];
                    }
                    else
                    {
                        [alert setInformativeText:NSLocalizedString(@"Do you wish to remove it anyway ?", @"Trash removal question")];
                        [alert addButtonWithTitle:NSLocalizedString(@"Remove", @"Button text for remove action")];
                    }
                    [alert setAlertStyle:NSCriticalAlertStyle];

                    BOOL applyToAll = NO;
                    if(q.hasNextItem)
                    {
                        [alert setShowsSuppressionButton:YES];
                        [[alert suppressionButton] setTitle:
                            NSLocalizedString(@"Apply to all", @"Confirmation text")];
                    }
                    NSInteger returnCode = [alert runModal];
                    if([alert showsSuppressionButton])
                        applyToAll = [[alert suppressionButton] state] == NSOnState;
                    [alert release];
                    if(returnCode == NSAlertFirstButtonReturn)
                        handling = KeepTempFileTrashHandling;
                    else
                        handling = RemoveTrashFailedTrashHandling;
                    if(applyToAll)
                        q.removeWhenTrashFailes = handling;
                }
                needsRemoval = handling == RemoveTrashFailedTrashHandling;
                shouldKeepOld = handling == KeepTempFileTrashHandling;
            }
        }
        if(needsRemoval && ![mgr removeItemAtPath:[edits loadedFileName] error:&error])
        {
            NSString* msg = [NSString stringWithFormat:
                NSLocalizedString(@"Failed to remove loaded file: %@", @"Remove loaded error"),
                [error localizedDescription]];
            self.status = msg;
            MZLoggerError(@"Failed to remove loaded file: %@", [error localizedDescription]);
            error = nil;
        }
        else
        {
            if( shouldKeepOld && [[edits loadedFileName] isEqualToString:[edits savedFileName]])
            {
                NSString* tempFile = [edits loadedFileName];
                while([mgr fileExistsAtPath:tempFile])
                {
                    NSString* ext = [tempFile pathExtension];
                    tempFile = [[tempFile stringByDeletingPathExtension] stringByAppendingString:@" Backup"];
                    if(ext && [ext length] > 0)
                        tempFile = [tempFile stringByAppendingFormat:@".%@", ext];
                }
                
                if(![mgr moveItemAtPath:[edits loadedFileName] toPath:tempFile error:&error])
                {
                    NSString* msg = [NSString stringWithFormat:
                        NSLocalizedString(@"Failed to move original file to backup: %@", @"Move to backup error"),
                        [error localizedDescription]];
                    self.status = msg;
                    MZLoggerError(@"Failed to move original file to backup: %@", [error localizedDescription]);
                    error = nil;
                    shouldMove = NO;
                }
            }
            
            if( (shouldMove || ![[edits loadedFileName] isEqualToString:[edits savedFileName]]) &&
                ![mgr moveItemAtPath:[edits savedTempFileName] toPath:[edits savedFileName] error:&error])
            {
                NSString* msg = [NSString stringWithFormat:
                    NSLocalizedString(@"Failed to move file to final location: %@", @"Move to final location error"),
                    [error localizedDescription]];
                self.status = msg;
                MZLoggerError(@"Failed to move file to final location: %@", [error localizedDescription]);
                error = nil;
            }
        }
    }
    else if(![[edits loadedFileName] isEqualToString:[edits savedFileName]])
    {
        if(![mgr moveItemAtPath:[edits loadedFileName] toPath:[edits savedFileName] error:&error])
        {
            NSString* msg = [NSString stringWithFormat:
                NSLocalizedString(@"Failed to move file to final location: %@", @"Move to final location error"),
                [error localizedDescription]];
            MZLoggerError(@"Failed to move file to final location: %@", [error localizedDescription]);
            self.status = msg;
            error = nil;
        }
    }
    self.completed = error == nil;
    
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:edits forKey:MZMetaEditsNotificationKey];
    if(error)
    {
        [[NSNotificationCenter defaultCenter]
                postNotificationName:MZQueueItemFailed
                              object:self
                            userInfo:userInfo];
    } else
    {
        [[NSNotificationCenter defaultCenter]
                postNotificationName:MZQueueItemCompleted
                              object:self
                            userInfo:userInfo];
    }

    [self finished];
}

- (void)triggerChangeNotification:(int)changes
{
    if(changes==0) return;
    NSArray* keys = [NSArray arrayWithObjects:@"changes", nil];
    NSArray* values = [NSArray arrayWithObjects:[NSNumber numberWithInt:changes], nil];
    NSDictionary* userInfo = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    [[NSNotificationCenter defaultCenter]
            postNotificationName:MZQueueCompletedPercent
                          object:self
                        userInfo:userInfo];
}

@end
