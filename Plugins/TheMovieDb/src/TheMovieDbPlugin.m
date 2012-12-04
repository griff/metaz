//
//  TheMovieDbPlugin.m
//  MetaZ
//
//  Created by Brian Olsen on 29/12/11.
//  Copyright 2011 Maven-Group. All rights reserved.
//

#import "TheMovieDbPlugin.h"
#import "TheMovieDbSearch.h"

@implementation TheMovieDbPlugin

- (void)dealloc
{
    [supportedSearchTags release];
    [menu release];
    [super dealloc];
}

- (void)didLoad
{
    [MZTag registerTag:[MZStringTag tagWithIdentifier:TMDbIdTagIdent]];
    [MZTag registerTag:[MZStringTag tagWithIdentifier:TMDbURLTagIdent]];
    [super didLoad];
}

- (BOOL)isBuiltIn
{
    return YES;
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
        menu = [[NSMenu alloc] initWithTitle:@"TheMovieDb"];
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
    NSString* str = [[result valueForKey:TMDbURLTagIdent] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL* url = [NSURL URLWithString:str];
    [[NSWorkspace sharedWorkspace] openURL:url];
}


- (BOOL)searchWithData:(NSDictionary *)data
              delegate:(id<MZSearchProviderDelegate>)delegate
                 queue:(NSOperationQueue *)queue;
{
    [self cancelSearch];

    NSNumber* videoKindObj = [data objectForKey:MZVideoTypeTagIdent];
    NSString* title = [data objectForKey:MZTitleTagIdent];
    if(!([videoKindObj intValue] == MZMovieVideoType && title && [title length] > 0))
    {
        return NO;
    }
    
    TheMovieDbSearch* search = [TheMovieDbSearch searchWithProvider:self delegate:delegate queue:queue];
    [search fetchMovieSearch:title];
    
    [self startSearch:search];
    MZLoggerDebug(@"Sent request to TheMovieDb");
    [search addOperationsToQueue:queue];
    return YES;
}

@end
