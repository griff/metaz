//
//  IMDBSearchProvider.m
//  MetaZ
//
//  Created by Brian Olsen on 23/12/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "IMDBSearchProvider.h"


@implementation IMDBSearchProvider

- (void)dealloc
{
    [search release];
    [icon release];
    [supportedSearchTags release];
    [menu release];
    [super dealloc];
}

- (NSImage *)icon
{
    if(!icon)
    {
        icon = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://www.imdb.com/favicon.ico"]];
    }
    return icon;
}

- (NSString *)identifier
{
    return @"org.maven-group.MetaZ.IMDBPlugin";
}

- (NSArray *)supportedSearchTags
{
    if(!supportedSearchTags)
    {
        NSMutableArray* ret = [NSMutableArray array];
        [ret addObject:[MZTag tagForIdentifier:MZTitleTagIdent]];
        [ret addObject:[MZTag tagForIdentifier:MZVideoTypeTagIdent]];
        supportedSearchTags = [[NSArray alloc] initWithArray:ret];
    }
    return supportedSearchTags;
}

- (NSMenu *)menuForResult:(MZSearchResult *)result
{
    if(!menu)
    {
        menu = [[NSMenu alloc] initWithTitle:@"IMDB"];
        NSMenuItem* item = [menu addItemWithTitle:@"View in Browser" action:@selector(view:) keyEquivalent:@""];
        [item setTarget:self];
    }
    for(NSMenuItem* item in [menu itemArray])
        [item setRepresentedObject:result];
    return menu;
}

- (void)view:(id)sender
{
    MZSearchResult* result = [sender representedObject];
    NSString* asin = [result valueForKey:@"imdb"];
    
    NSString* str = [[NSString stringWithFormat:
        @"http://amzn.com/%@",
        asin] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL* url = [NSURL URLWithString:str];
    [[NSWorkspace sharedWorkspace] openURL:url];
}

- (BOOL)searchWithData:(NSDictionary *)data delegate:(id<MZSearchProviderDelegate>)delegate;
{
    NSString* title = [data objectForKey:MZTitleTagIdent];

    if(search)
    {
        // Finish last search;
        [search cancel];
        [search release];
        search = nil;
    }

    if(!(title && [title length] > 0))
        return NO;

    MZLoggerDebug(@"Sent request to IMDB: %@", title);
    search = [[IMDBSearch alloc] initWithTitle:title delegate:delegate];
    [search start];
    return YES;
}

@end
