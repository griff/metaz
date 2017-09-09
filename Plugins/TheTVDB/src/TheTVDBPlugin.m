//
//  TheTVDBPlugin.m
//  MetaZ
//
//  Created by Nigel Graham on 09/04/10.
//  Copyright 2010 Maven-Group. All rights reserved.
//

#import "TheTVDBPlugin.h"
#import "TheTVDBSearch.h"


@implementation TheTVDBPlugin

- (void)dealloc
{
    [supportedSearchTags release];
    [menu release];
    [super dealloc];
}

- (void)didLoad
{
    [MZTag registerTag:[MZStringTag tagWithIdentifier:TVDBEpisodeIdTagIdent]];
    [MZTag registerTag:[MZStringTag tagWithIdentifier:TVDBSeasonIdTagIdent]];
    [MZTag registerTag:[MZStringTag tagWithIdentifier:TVDBSeriesIdTagIdent]];
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
        NSMenuItem* item = [menu addItemWithTitle:@"View episode in Browser" action:@selector(view:) keyEquivalent:@""];
        [item setTarget:self];
        item = [menu addItemWithTitle:@"View season in Browser" action:@selector(viewSeason:) keyEquivalent:@""];
        [item setTarget:self];
        item = [menu addItemWithTitle:@"View series in Browser" action:@selector(viewSeries:) keyEquivalent:@""];
        [item setTarget:self];
    }
    for(NSMenuItem* item in [menu itemArray])
        [item setRepresentedObject:result];
    return menu;
}

- (void)view:(id)sender
{
    MZSearchResult* result = [sender representedObject];
    NSNumber* series = [result valueForKey:TVDBSeriesIdTagIdent];
    NSString* season = [result valueForKey:TVDBSeasonIdTagIdent];
    NSString* episode = [result valueForKey:TVDBEpisodeIdTagIdent];
    
    NSString* str = [[NSString stringWithFormat:
        @"http://thetvdb.com/?tab=episode&seriesid=%d&seasonid=%@&id=%@",
        [series unsignedIntValue], season, episode]
                     stringByAddingPercentEncodingWithAllowedCharacters: [NSCharacterSet URLQueryAllowedCharacterSet]
                     ];
    NSURL* url = [NSURL URLWithString:str];
    [[NSWorkspace sharedWorkspace] openURL:url];
}

- (void)viewSeason:(id)sender
{
    MZSearchResult* result = [sender representedObject];
    NSNumber* series = [result valueForKey:TVDBSeriesIdTagIdent];
    NSString* season = [result valueForKey:TVDBSeasonIdTagIdent];
    
    NSString* str = [[NSString stringWithFormat:
        @"http://thetvdb.com/?tab=season&seriesid=%d&seasonid=%@",
        [series unsignedIntValue], season]
                     stringByAddingPercentEncodingWithAllowedCharacters: [NSCharacterSet URLQueryAllowedCharacterSet]
                     ];
    NSURL* url = [NSURL URLWithString:str];
    [[NSWorkspace sharedWorkspace] openURL:url];
}

- (void)viewSeries:(id)sender
{
    MZSearchResult* result = [sender representedObject];
    NSNumber* series = [result valueForKey:TVDBSeriesIdTagIdent];
    
    NSString* str = [[NSString stringWithFormat:
        @"http://thetvdb.com/?tab=series&id=%d",
        [series unsignedIntValue]]
                     stringByAddingPercentEncodingWithAllowedCharacters: [NSCharacterSet URLQueryAllowedCharacterSet]
                     ];
    NSURL* url = [NSURL URLWithString:str];
    [[NSWorkspace sharedWorkspace] openURL:url];
}


- (BOOL)searchWithData:(NSDictionary *)data
              delegate:(id<MZSearchProviderDelegate>)delegate
                 queue:(NSOperationQueue *)queue;
{
    [self cancelSearch];

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
    
    TheTVDBSearch* search = [TheTVDBSearch searchWithProvider:self delegate:delegate queue:queue];
    search.season = season;
    search.episode = episode;
    [search updateMirror];
    [search fetchSeriesByName:show];
    
    [self startSearch:search];
    MZLoggerDebug(@"Sent request to TheTVDB");
    [search addOperationsToQueue:queue];
    return YES;
}

@end
