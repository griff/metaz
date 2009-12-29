//
//  IMDBSearch.m
//  MetaZ
//
//  Created by Brian Olsen on 23/12/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "IMDBSearch.h"
#import <MetaZKit/GTMNSString+URLArguments.h>

@implementation IMDBSearch

- (id)initWithTitle:(NSString *)theTitle delegate:(id<MZSearchProviderDelegate>)theDelegate
{
    self = [super init];
    if(self)
    {
        title = [theTitle retain];
        delegate = [theDelegate retain];
        scraper = [[NSClassFromString(@"IMDBScraper") alloc] init];
        queue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [title release];
    [delegate release];
    [scraper release];
    [queue release];
    [super dealloc];
}

- (void)cancel
{
    [super cancel];
    [queue cancelAllOperations];
}

- (void)main
{
    if([self isCancelled])
    {
        [delegate performSelectorOnMainThread:@selector(searchFinished) withObject:nil waitUntilDone:NO];
        return;
    }
        
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.imdb.com/find?s=tt&q=%@",
        [title gtm_stringByEscapingForURLArgument]]]; 
    NSData* data = [NSData dataWithContentsOfURL:url];
    NSString* str = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    //MZLoggerDebug(@"Got IMDB data: %@", str);

    if([self isCancelled])
    {
        [delegate performSelectorOnMainThread:@selector(searchFinished) withObject:nil waitUntilDone:NO];
        return;
    }
    [self performSelectorOnMainThread:@selector(scrape:) withObject:str waitUntilDone:YES];
    [queue waitUntilAllOperationsAreFinished];
    [delegate performSelectorOnMainThread:@selector(searchFinished) withObject:nil waitUntilDone:NO];
}

- (void)scrape:(NSString *)str
{
    [scraper parseData:str withQueue:queue delegate:delegate];
}

@end
