//
//  OSXNotificationPlugin.m
//  MetaZ
//
//  Created by Brian Olsen on 24/11/13.
//
//

#import "OSXNotificationPlugin.h"
#import "MZNotification.h"

@implementation OSXNotificationPlugin

- (void)dealloc
{
    [startTime release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)didLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(queueStarted:)
                                                 name:MZQueueStartedNotification
                                               object:nil];
    
    [MZNotification setDelegate:self];
    [super didLoad];
}

- (void)willUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)unregisterObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MZQueueItemCompletedNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MZQueueItemFailedNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MZQueueCompletedNotification
                                                  object:nil];
}

- (void)registerObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(queueItemCompleted:)
                                                 name:MZQueueItemCompletedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(queueItemFailed:)
                                                 name:MZQueueItemFailedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(queueCompleted:)
                                                 name:MZQueueCompletedNotification
                                               object:nil];
}

#pragma mark - as NSUserNotificationCenterDelegate

- (void)userNotificationCenter:(id)center didActivateNotification:(id)notification
{
    NSDictionary* userInfo = [notification userInfo];
    NSString* path = [userInfo objectForKey:@"MZPath"];
    if(path)
        [[NSWorkspace sharedWorkspace] selectFile:path
                         inFileViewerRootedAtPath:@""];
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
    [MZNotification notifyWithTitle:NSLocalizedString(@"File writing completed", @"Notification for when writing failed")
                        description:[NSString stringWithFormat:
                                          NSLocalizedString(@"Completed writing %@", @"Notification description format for when writing completes"),
                                          [[edits savedFileName] lastPathComponent]]
                               path:[edits savedFileName]];
}

- (void)queueItemFailed:(NSNotification *)note
{
    MetaEdits* edits = [[note userInfo] objectForKey:MZMetaEditsNotificationKey];
    [MZNotification notifyWithTitle:NSLocalizedString(@"File writing failed", @"Notification for when writing failed")
                        description:[NSString stringWithFormat:
                                     NSLocalizedString(@"Failed writing %@", @"Notification description format for when writing failed"),
                                          [[edits savedFileName] lastPathComponent]]
                               path:[edits loadedFileName]];
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
    
    [MZNotification notifyWithTitle:title
                        description:msg
                               path:nil];
}

@end
