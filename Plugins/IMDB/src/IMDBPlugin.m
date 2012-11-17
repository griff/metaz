//
//  IMDBPlugin.m
//  MetaZ
//
//  Created by Brian Olsen on 20/12/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "IMDBPlugin.h"
#import <RubyCocoa/RBRuntime.h>

@implementation IMDBPlugin

- (void)dealloc
{
    [supportedSearchTags release];
    [menu release];
    [super dealloc];
}

- (void)didLoad
{
    RBBundleInit("imdb_plugin.rb", [self class], nil);
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

- (BOOL)searchWithData:(NSDictionary *)data
              delegate:(id<MZSearchProviderDelegate>)delegate
                 queue:(NSOperationQueue *)queue;
{
    NSString* title = [data objectForKey:MZTitleTagIdent];

    [self cancelSearch];

    if(!(title && [title length] > 0))
        return NO;

    MZLoggerDebug(@"Sent request to IMDB: %@", title);
    IMDBSearch* search = [[IMDBSearch alloc] initWithTitle:title delegate:delegate];
    [self startSearch:search];
    [queue addOperation:search];
    return YES;
}

@end
