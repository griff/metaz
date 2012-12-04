//
//  AlertWindowPlugin.m
//  MetaZ
//
//  Created by Brian Olsen on 06/11/12.
//  Copyright 2012 Maven-Group. All rights reserved.
//

#import "AlertWindowPlugin.h"


@implementation AlertWindowPlugin

- (void)dealloc
{
    [startTime release];
    [[NSNotificationCenter defaultCenter]
        removeObserver:self];
    [super dealloc];
}

- (void)didLoad
{
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(queueStarted:)
               name:MZQueueStartedNotification
             object:nil];

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
                  name:MZQueueCompletedNotification
                object:nil];
}

- (void)registerObservers
{
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(queueCompleted:)
               name:MZQueueCompletedNotification
             object:nil];
}

#pragma mark - notifications

- (void)queueStarted:(NSNotification *)note
{    
    [startTime release];
    startTime = [[NSDate alloc] init];
}

- (void)queueCompletedDelayed:(NSNotification *)note
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
    
    NSRunAlertPanel( title, msg, NSLocalizedString(@"OK", @"OK button text"), nil, nil);
}

- (void)queueCompleted:(NSNotification *)note
{
    [self performSelector:@selector(queueCompletedDelayed:) withObject:note afterDelay:0.1];
}

@end
