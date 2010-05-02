//
//  TheTVDBSearchProvider.m
//  MetaZ
//
//  Created by Nigel Graham on 09/04/10.
//  Copyright 2010 Maven-Group. All rights reserved.
//

#import "TheTVDBSearchProvider.h"
#import "TheTVDBPlugin.h"

@implementation TheTVDBSearchProvider

- (void)dealloc
{
    //[search release];
    [icon release];
    [supportedSearchTags release];
    [menu release];
    [super dealloc];
}

- (NSImage *)icon
{
    if(!icon)
    {
        icon = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://thetvdb.com/favicon.ico"]];
    }
    return icon;
}

- (NSString *)identifier
{
    return @"org.maven-group.MetaZ.TheTVDBPlugin";
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
        menu = [[NSMenu alloc] initWithTitle:@"TheTVDB"];
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
    NSString* query = [result valueForKey:EpisodeQueryTagIdent];
    
    NSString* str = [[NSString stringWithFormat:
        @"http://thetvdb.com/?tab=episode&%@",
        query] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL* url = [NSURL URLWithString:str];
    [[NSWorkspace sharedWorkspace] openURL:url];
}

- (BOOL)searchWithData:(NSDictionary *)data
              delegate:(id<MZSearchProviderDelegate>)delegate
                 queue:(NSOperationQueue *)queue;
{
    if(search)
    {
        // Finish last search;
        [search cancel];
        [search release];
        search = nil;
    }

    NSNumber* videoKindObj = [data objectForKey:MZVideoTypeTagIdent];
    NSString* show = [data objectForKey:MZTVShowTagIdent];
    NSNumber* seasonNo = [data objectForKey:MZTVSeasonTagIdent];
    NSNumber* episodeNo = [data objectForKey:MZTVEpisodeTagIdent];
    if(!([videoKindObj intValue] == MZTVShowVideoType && show && seasonNo))
    {
        return NO;
    }
    
    NSUInteger season = [seasonNo integerValue];
    NSInteger episode = -1;
    if(episodeNo)
        episode = [episodeNo integerValue];
    
    search = [[TheTVDBSearch alloc] initWithProvider:self delegate:delegate queue:queue];
    
    /*
    TheTVDBUpdateMirrors* mirrors = [[TheTVDBUpdateMirrors alloc] init];
    [search addOperation:mirrors];
    [mirrors release];
    */
    
    TheTVDBGetSeries* seriesSearch = [[TheTVDBGetSeries alloc] initWithSearch:search name:show season:season episode:episode];
    //[seriesSearch addDependency:mirrors];
    [search addOperation:seriesSearch];
    [seriesSearch release];
    
    MZLoggerDebug(@"Sent request to TheTVDB");
    [search addOperationsToQueue:queue];
    return YES;
}

@end
