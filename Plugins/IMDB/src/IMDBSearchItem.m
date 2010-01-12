//
//  IMDBSearchItem.m
//  MetaZ
//
//  Created by Brian Olsen on 23/12/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "IMDBSearchItem.h"


@implementation IMDBSearchItem

- (id)initWithIdentifier:(NSString *)theIdent
                   title:(NSString *)theTitle
                 scraper:(id<IMDBScraperProtocol>)theScraper
                delegate:(id<MZSearchProviderDelegate>)theDelegate
{
    self = [super init];
    if(self)
    {
        ident = [theIdent retain];
        title = [theTitle retain];
        scraper = [theScraper retain];
        delegate = [theDelegate retain];
    }
    return self;
}

- (void)dealloc
{
    [ident release];
    [title release];
    [scraper release];
    [delegate release];
    [super dealloc];
}

- (void)main
{
    if([self isCancelled])
        return;

    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.imdb.com/find?s=tt&q=%@",
        [title gtm_stringByEscapingForURLArgument]]]; 
    NSData* data = [NSData dataWithContentsOfURL:url];
    NSString* str = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];

    if([self isCancelled])
        return;

    [self performSelectorOnMainThread:@selector(scrape:) withObject:str waitUntilDone:YES];
}

- (void)scrape:(NSString *)str
{
    [scraper parseMovie:str delegate:delegate];
}


@end
