//
//  MZWriteQueueStatus.m
//  MetaZ
//
//  Created by Brian Olsen on 29/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "MZWriteQueueStatus.h"
#import "MZWriteQueue.h"
#import "MZWriteQueue-Private.h"
#import "MZMetaLoader.h"


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

- (void)stopWritingAndRemove
{
    if(controller && [controller isRunning])
    {
        removeOnCancel = YES;
        [controller terminate];
    }
    else
    {
        [[MZMetaLoader sharedLoader] reloadEdits:edits];
        [[MZWriteQueue sharedQueue] removeObjectFromQueueItems:self];
    }
}

- (void)writeCanceled
{
    [self willChangeValueForKey:@"writing"];
    writing = 0;
    [self didChangeValueForKey:@"writing"];
    if(removeOnCancel)
    {
        [[MZMetaLoader sharedLoader] reloadEdits:edits];
        [[MZWriteQueue sharedQueue] removeObjectFromQueueItems:self];
        [[MZWriteQueue sharedQueue] startNextItem];
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
}

- (void)writeFinishedPercent:(int)newPercent
{
    [self willChangeValueForKey:@"percent"];
    percent = newPercent;
    [self didChangeValueForKey:@"percent"];
}

- (void)writeFinished
{
    MZWriteQueue* q = [MZWriteQueue sharedQueue];
    NSFileManager* mgr = [NSFileManager defaultManager];
    NSError* error = nil;

    BOOL isDir = NO;
    if([mgr fileExistsAtPath:[edits savedTempFileName] isDirectory:&isDir] && !isDir)
    {
        BOOL putOriginalsInTrash = [[NSUserDefaults standardUserDefaults] boolForKey:@"putOriginalsInTrash"];
        BOOL needsRemoval = !putOriginalsInTrash;
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
                if(handling == UseDefaultTrashHandling)
                {
                    NSAlert* alert = [[NSAlert alloc] init];
                    NSString* title = [NSString stringWithFormat:
                            NSLocalizedString(@"Unable to put original \"%@\" in trash", @"Trash title"),
                            [[edits loadedFileName] lastPathComponent]];
                    [alert setMessageText:title];
                    [alert setInformativeText:NSLocalizedString(@"Do you wish to remove it anyway ?", @"Trash removal question")];
                    [alert setAlertStyle:NSCriticalAlertStyle];
                    [alert addButtonWithTitle:NSLocalizedString(@"Remove", @"Button text for remove action")];
                    [alert addButtonWithTitle:NSLocalizedString(@"Keep", @"Button text for keep action")];

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
                        handling = RemoveTrashFailedTrashHandling;
                    else
                        handling = KeepTempFileTrashHandling;
                    if(applyToAll)
                        q.removeWhenTrashFailes = handling;
                }
                needsRemoval = handling == RemoveTrashFailedTrashHandling;
            }
        }
        if(needsRemoval && ![mgr removeItemAtPath:[edits loadedFileName] error:&error])
        {
            NSLog(@"Failed to remove loaded file %@", [error localizedDescription]);
            error = nil;
        }
        
        if(![mgr moveItemAtPath:[edits savedTempFileName] toPath:[edits savedFileName] error:&error])
        {
            NSLog(@"Failed to move file to final location %@", [error localizedDescription]);
            error = nil;
        }
    }
    else if(![[edits loadedFileName] isEqualToString:[edits savedFileName]])
    {
        if(![mgr moveItemAtPath:[edits loadedFileName] toPath:[edits savedFileName] error:&error])
        {
            NSLog(@"Failed to move file to final location %@", [error localizedDescription]);
            error = nil;
        }
    }

    [self willChangeValueForKey:@"writing"];
    writing = 0;
    [self didChangeValueForKey:@"writing"];
    [q willChangeValueForKey:@"completedItems"];
    [self willChangeValueForKey:@"completed"];
    completed = YES;
    [self didChangeValueForKey:@"completed"];
    [q didChangeValueForKey:@"completedItems"];
    [[MZWriteQueue sharedQueue] startNextItem];
}


@end
