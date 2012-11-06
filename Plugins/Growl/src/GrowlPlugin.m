//
//  GrowlPlugin.m
//  MetaZ
//
//  Created by Brian Olsen on 06/11/12.
//  Copyright 2012 Maven-Group. All rights reserved.
//

#import "GrowlPlugin.h"
#import "MZMultiGrowlWrapper.h"

@implementation GrowlPlugin

- (void)dealloc
{
    [startTime release];
    [[NSNotificationCenter defaultCenter]
        removeObserver:self];
    [super dealloc];
}

- (BOOL)isEnabled
{
    return [MZMultiGrowlWrapper isGrowlSupported] && [super isEnabled];
}

- (BOOL)canEnable
{
    return [MZMultiGrowlWrapper isGrowlSupported];
}

- (void)didLoad
{
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(queueStarted:)
               name:MZQueueStartedNotification
             object:nil];

    [MZMultiGrowlWrapper setGrowlDelegate:self];
    [super didLoad];
}

- (void)willUnload
{
    [[NSNotificationCenter defaultCenter]
        removeObserver:self];
}

- (void)unregisterObservers
{
    [[NSNotificationCenter defaultCenter]
        removeObserver:self
                  name:MZQueueItemCompletedNotification
                object:nil];
    [[NSNotificationCenter defaultCenter]
        removeObserver:self
                  name:MZQueueItemFailedNotification
                object:nil];
    [[NSNotificationCenter defaultCenter]
        removeObserver:self
                  name:MZQueueCompletedNotification
                object:nil];
}

- (void)registerObservers
{
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(queueItemCompleted:)
               name:MZQueueItemCompletedNotification
             object:nil];

    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(queueItemFailed:)
               name:MZQueueItemFailedNotification
             object:nil];

    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(queueCompleted:)
               name:MZQueueCompletedNotification
             object:nil];
}

#pragma mark - as Growl delegate

- (void) growlNotificationWasClicked:(id)clickContext
{
    NSString* path = clickContext;
    [[NSWorkspace sharedWorkspace]
                      selectFile:path
        inFileViewerRootedAtPath:@""];
}

- (NSDictionary *) registrationDictionaryForGrowl;
{
    NSArray* notifs = [NSArray arrayWithObjects:
        @"File writing completed", @"File writing failed",
        @"Queue processing completed", nil];
    
    NSDictionary* humanNames = [NSDictionary dictionaryWithObjects:
        [NSArray arrayWithObjects:
            NSLocalizedString(@"File writing completed", @"Human notification name for when writing completes"),
            NSLocalizedString(@"File writing failed", @"Human notification name for when writing failes"),
            NSLocalizedString(@"Queue processing completed", @"Human notification name when queue completes"),
            nil]
        forKeys:notifs];
    return [NSDictionary dictionaryWithObjectsAndKeys:
        notifs, @"AllNotifications",
        notifs, @"DefaultNotifications",
        humanNames, @"HumanReadableNames",
        nil];
}

#pragma mark - notifications

- (void)queueStarted:(NSNotification *)note
{    
    [startTime release];
    startTime = [[NSDate alloc] init];
}

- (void)queueItemCompleted:(NSNotification *)note
{
    MetaEdits* edits = [[note userInfo] objectForKey:MZMetaEditsNotificationKey];
    [MZMultiGrowlWrapper
        notifyWithTitle:NSLocalizedString(@"File writing completed", @"Notification for when writing failed")
            description:[NSString stringWithFormat:
                NSLocalizedString(@"Completed writing %@", @"Notification description format for when writing completes"),
                            [[edits savedFileName] lastPathComponent]]
       notificationName:@"File writing completed"
               iconData:[edits picture]
               priority:0
               isSticky:NO
           clickContext:[edits savedFileName]];
}

- (void)queueItemFailed:(NSNotification *)note
{
    MetaEdits* edits = [[note userInfo] objectForKey:MZMetaEditsNotificationKey];
    [MZMultiGrowlWrapper
        notifyWithTitle:NSLocalizedString(@"File writing failed", @"Notification for when writing failed")
            description:[NSString stringWithFormat:
                NSLocalizedString(@"Failed writing %@", @"Notification description format for when writing failed"),
                            [[edits savedFileName] lastPathComponent]]
       notificationName:@"File writing failed"
               iconData:[edits picture]
               priority:0
               isSticky:NO
           clickContext:[edits loadedFileName]];
}

- (void)queueCompleted:(NSNotification *)note
{
    NSString* intervalStr;
    NSTimeInterval interval = [startTime timeIntervalSinceNow]*-1.0;
    if(interval > 86400) // Days
    {
        interval = interval/86400;
        intervalStr = [NSString stringWithFormat:NSLocalizedString(@"%1.1f days", @"Days interval"), interval];
    }
    else if (interval > 3600) // Hours
    {
        interval = interval/3600;
        intervalStr = [NSString stringWithFormat:NSLocalizedString(@"%1.1f hours", @"Hours interval"), interval];
    }
    else if (interval > 60) // Minutes
    {
        interval = interval/60;
        intervalStr = [NSString stringWithFormat:NSLocalizedString(@"%1.1f min", @"Minutes interval"), interval];
    }
    else
    {
        intervalStr = [NSString stringWithFormat:NSLocalizedString(@"%1.0f sec", @"Seconds interval"), interval];
    }
    
    NSString * title = NSLocalizedString(@"Queue run completed", @"Queue completed title");
    NSString * msg = [NSString stringWithFormat:
                      NSLocalizedString(@"Your MetaZ queue completed in %@",
                                        "Queue completed alert message"),
                      intervalStr];
    
    [MZMultiGrowlWrapper
         notifyWithTitle:title
             description:msg
        notificationName:@"Queue processing completed"
                iconData:nil
                priority:0
                isSticky:NO
            clickContext:nil];
}

@end
