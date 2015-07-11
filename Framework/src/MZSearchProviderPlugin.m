//
//  MZSearchProviderPlugin.m
//  MetaZ
//
//  Created by Brian Olsen on 11/05/10.
//  Copyright 2010 Maven-Group. All rights reserved.
//

#import "MZSearchProviderPlugin.h"
#import "GTMNSObject+KeyValueObserving.h"

@implementation MZSearchProviderPlugin

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
    for(id canceledSearch in canceledSearches)
        [canceledSearch gtm_removeObserver:self forKeyPath:@"isFinished" selector:@selector(canceledSearchFinished:)];

    [search release];
    [canceledSearches release];
    [icon release];
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
}

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

- (NSImage *)icon;
{
    if(!icon)
    {
        NSString* iconString = [[self bundle] objectForInfoDictionaryKey:@"IconURL"];
        NSURL* iconURL = nil;
        if(iconString)
            iconURL = [NSURL URLWithString:iconString];
        else
        {
            NSString* iconFile = [[self bundle] objectForInfoDictionaryKey:@"CFBundleIconFile"];
            if(iconFile)
            {
                iconFile = [[self bundle] pathForResource:iconFile ofType:nil];
                if(iconFile)
                    iconURL = [NSURL fileURLWithPath:iconFile];
            }
        }
        if(!iconURL)
            return nil;
        icon = [[NSImage alloc] initWithContentsOfURL:iconURL];
		if (!icon)
		{
			// We couldn't load the required icon. Fallback to a warning icon.
			icon = [[[NSWorkspace sharedWorkspace]
					 iconForFileType:NSFileTypeForHFSTypeCode(kAlertCautionIcon)] retain];
		}
    }
    return icon;
}

- (NSArray *)supportedSearchTags;
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (BOOL)searchWithData:(NSDictionary *)data
              delegate:(id<MZSearchProviderDelegate>)delegate
                 queue:(NSOperationQueue *)queue;
{
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

- (NSMenu *)menuForResult:(MZSearchResult *)result;
{
    return nil;
}

@end
