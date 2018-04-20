//
//  NSApplication+MetaZApplication.m
//  MetaZ
//
//  Created by Brian Olsen on 14/07/12.
//  Copyright 2012 Maven-Group. All rights reserved.
//

#import "MetaZApplication.h"
#import "MZSelectedMetaDataDocument.h"
#import "MZMetaLoader.h"
#import "MZWriteQueue.h"
#import "MZWriteQueueStatus.h"
#import <MetaZKit/MZLogger.h>
#import <Sparkle/Sparkle.h>

@implementation MetaZApplication
@synthesize filesController;

- (id)handleOpenScriptCommand:(NSScriptCommand *)test;
{
    id direct = [test directParameter];
    MZLoggerDebug(@"Handle open: %@ %@", direct, [test evaluatedArguments]);
    if([direct isKindOfClass:[NSArray class]])
    {
        NSMutableArray *names = [NSMutableArray arrayWithCapacity:[direct count]];
        for(NSURL* url in direct)
            [names addObject:[url path]];
        [[self delegate] application:self openFiles:names];
    }
    else
    {
        [[self delegate] application:self openFile:[direct path]];
        NSArray* files = [MZMetaLoader sharedLoader].files;
        for(MetaEdits* edit in files)
        {
            if([[edit loadedFileName] isEqualToString:[direct path]])
            {
                return [MZMetaDataDocument documentWithEdit:edit];
            }
        }
    }
    return nil;
}

- (id)handleQuitLaterScriptCommand:(NSScriptCommand *)test;
{
    [self performSelector:@selector(laterQuit) withObject:nil afterDelay:1];
    return nil;
}

- (void)laterQuit
{
    if([[MZWriteQueue sharedQueue] status] == QueueRunning ||
        [[MZWriteQueue sharedQueue] status] == QueueStopping)
    {
        [self performSelector:@selector(laterQuit) withObject:nil afterDelay:1];
    }
    else
        [NSApp terminate:self];
}

- (void)setSelectedDocuments:(id)sel
{
    if([sel isKindOfClass:[NSArray class]])
        sel = [sel arrayByPerformingSelector:@selector(data)];
    else
        sel = [NSArray arrayWithObject:[sel data]];
    [filesController setSelectedObjects:sel];
}

- (id)selectedDocuments;
{
    NSMutableArray* arr = [NSMutableArray array];
    for(MetaEdits* edit in [filesController selectedObjects])
        [arr addObject:[MZSelectedMetaDataDocument documentWithEdit:edit]];
    return arr;
}

- (id)selection;
{
    NSArray* sel = [self selectedDocuments];
    if([sel count] == 0)
        return nil;
    if([sel count]==1)
        return [sel objectAtIndex:0];
    return sel;
}

- (void)setSelection:(id)sel;
{
    [self setSelectedDocuments:sel];
}

- (NSArray *)orderedDocuments
{
    if(!documents)
        documents = [[NSMutableArray alloc] init];
    [documents removeAllObjects];
    
    NSArray* files = [filesController arrangedObjects];
    for(MetaEdits* edit in files)
    {
        [documents addObject:[MZMetaDataDocument documentWithEdit:edit]];
    }
    return documents;
}

- (NSArray *)queueDocuments
{
    NSMutableArray* queue = [NSMutableArray array];
    for(MZWriteQueueStatus* item in [[MZWriteQueue sharedQueue] queueItems])
    {
        [queue addObject:[MZMetaDataDocument
            documentWithEdit:[item edits]
                   container:@"queueDocuments"
                       saved:item.completed]];
    }
    return queue;
}

- (IBAction)updateFeedURL:(id)button {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"updateIncludePrerelease"]) {
        NSURL *url = [NSURL URLWithString: [[NSBundle mainBundle]objectForInfoDictionaryKey:@"SUFeedURL"]];
        NSURL *prerelease = [NSURL URLWithString: @"appcast-prerelease.xml" relativeToURL:url];
        [[SUUpdater sharedUpdater] setFeedURL:prerelease];
    } else {
        NSURL *url = [NSURL URLWithString: [[NSBundle mainBundle] objectForInfoDictionaryKey:@"SUFeedURL"]];
        [[SUUpdater sharedUpdater] setFeedURL:url];
    }
}

@end
