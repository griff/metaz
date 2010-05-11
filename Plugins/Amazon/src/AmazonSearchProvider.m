//
//  AmazonSearcher.m
//  MetaZ
//
//  Created by Brian Olsen on 18/11/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "AmazonSearchProvider.h"

@implementation AmazonSearchProvider

- (void)dealloc
{
    [icon release];
    [supportedSearchTags release];
    [menu release];
    [super dealloc];
}

- (NSImage *)icon
{
    if(!icon)
    {
        icon = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://www.amazon.com/favicon.ico"]];
    }
    return icon;
}

- (NSString *)identifier
{
    return @"org.maven-group.MetaZ.AmazonPlugin";
}

- (NSArray *)supportedSearchTags
{
    if(!supportedSearchTags)
    {
        NSMutableArray* ret = [NSMutableArray array];
        [ret addObject:[MZTag tagForIdentifier:MZTitleTagIdent]];
        [ret addObject:[MZTag tagForIdentifier:MZVideoTypeTagIdent]];
        [ret addObject:[MZTag tagForIdentifier:MZTVShowTagIdent]];
        [ret addObject:[MZTag tagForIdentifier:MZTVSeasonTagIdent]];
        supportedSearchTags = [[NSArray alloc] initWithArray:ret];
    }
    return supportedSearchTags;
}

- (NSMenu *)menuForResult:(MZSearchResult *)result
{
    if(!menu)
    {
        menu = [[NSMenu alloc] initWithTitle:@"Amazon"];
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
    NSString* asin = [result valueForKey:MZASINTagIdent];
    
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
    NSURL* searchURL = [NSURL URLWithString:@"http://ecs.amazonaws.com/onca/xml"];
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:@"ItemSearch" forKey:@"Operation"];
    [params setObject:@"DVD" forKey:@"SearchIndex"];
    [params setObject:@"Images,ItemAttributes,Request,Small,EditorialReview" forKey:@"ResponseGroup"];
    [params setObject:@"25" forKey:@"Count"];

    BOOL reallyDoSearch = NO;

    NSNumber* videoKindObj = [data objectForKey:MZVideoTypeTagIdent];
    if([videoKindObj intValue] == MZTVShowVideoType)
    {
        NSString* title = [data objectForKey:MZTVShowTagIdent];
        if(title)
        {
            NSNumber* season = [data objectForKey:MZTVSeasonTagIdent];
            if(season)
            {
                title = [NSString stringWithFormat:@"%@ season %d", title, [season intValue]];
            }
            [params setObject:title forKey:@"Title"];
            reallyDoSearch = YES;
        }
    }
    if(!reallyDoSearch)
    {
        NSString* title = [data objectForKey:MZTitleTagIdent];
        if(title && [title length] > 0)
        {   
            [params setObject:title forKey:@"Title"];
            reallyDoSearch = YES;
        }
    }
    
    [self cancelSearch];
            
    if(!reallyDoSearch)
        return NO;

    MZLoggerDebug(@"Sent request to Amazon:");
    for(NSString* key in [params allKeys])
        MZLoggerDebug(@"    '%@' -> '%@'", key, [params objectForKey:key]);
    AmazonSearch* search = [AmazonSearch searchWithProvider:self delegate:delegate url:searchURL parameters:params];
    [self startSearch:search];
    [queue addOperation:search];
    return YES;
}

@end
