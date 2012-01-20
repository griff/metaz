//
//  MZBaseSearchProvider.m
//  MetaZ
//
//  Created by Brian Olsen on 11/05/10.
//  Copyright 2010 Maven-Group. All rights reserved.
//

#import "MZBaseSearchProvider.h"
#import "GTMNSObject+KeyValueObserving.h"

@implementation MZBaseSearchProvider

- (id)init
{
    self = [super init];
    if(self)
    {
        canceledSearches = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    //[search gtm_removeObserver:self forKeyPath:@"isFinished" selector:@selector(searchFinished:)];
    for(id canceledSearch in canceledSearches)
        [canceledSearch gtm_removeObserver:self forKeyPath:@"isFinished" selector:@selector(canceledSearchFinished:)];

    [search release];
    [canceledSearches release];
    [super dealloc];
}

- (void)cancelSearch
{
    // Finish last search;
    if(search)
    {
        if([search respondsToSelector:@selector(isFinished)])
        {
            @synchronized(search)
            {
                if(![search isFinished])
                {
                    [canceledSearches addObject:search];
                    [search gtm_addObserver:self forKeyPath:@"isFinished" selector:@selector(canceledSearchFinished:) userInfo:nil options:0];
                }
                //[search gtm_removeObserver:self forKeyPath:@"isFinished" selector:@selector(searchFinished:)];
            }
            [search cancel];
            [search release];
            search = nil;
        }
    }
}

- (void)startSearch:(id)theSearch
{
    search = [theSearch retain];
    //[search gtm_addObserver:self forKeyPath:@"isFinished" selector:@selector(searchFinished:) userInfo:nil options:0];
}

/*
- (void)searchFinishedMain
{
    [search autorelease];
    search = nil;
}

- (void)searchFinished:(GTMKeyValueChangeNotification *)notification
{
    [search gtm_removeObserver:self forKeyPath:@"isFinished" selector:@selector(searchFinished:)];
    [self performSelectorOnMainThread:@selector(searchFinishedMain) withObject:nil waitUntilDone:YES];
}
*/

- (void)canceledSearchFinishedMain:(id)theSearch
{
    [canceledSearches removeObject:theSearch];
}

- (void)canceledSearchFinished:(GTMKeyValueChangeNotification *)notification
{
    [[notification object] gtm_removeObserver:self forKeyPath:@"isFinished" selector:@selector(canceledSearchFinished:)];
    [self performSelectorOnMainThread:@selector(canceledSearchFinishedMain:)
                           withObject:[notification object]
                        waitUntilDone:NO];
}

@end
