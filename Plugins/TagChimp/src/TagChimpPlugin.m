//
//  TagChimpPlugin.m
//  MetaZ
//
//  Created by Brian Olsen on 11/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "TagChimpPlugin.h"
#import "TCSearch.h"

static NSString* const TCToken = @"8363185134824C8CD908AA";

@implementation TagChimpPlugin

- (void)dealloc
{
    [supportedSearchTags release];
    [menu release];
    [super dealloc];
}

- (void)didLoad
{
    [MZTag registerTag:[MZIntegerTag tagWithIdentifier:TagChimpIdTagIdent]];
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
        [ret addObject:[MZTag tagForIdentifier:MZChaptersTagIdent]];
        [ret addObject:[MZTag tagForIdentifier:MZVideoTypeTagIdent]];
        [ret addObject:[MZTag tagForIdentifier:MZTVShowTagIdent]];
        [ret addObject:[MZTag tagForIdentifier:MZTVSeasonTagIdent]];
        [ret addObject:[MZTag tagForIdentifier:MZTVEpisodeTagIdent]];
        supportedSearchTags = [[NSArray alloc] initWithArray:ret];
    }
    return supportedSearchTags;
}

- (NSMenu *)menuForResult:(MZSearchResult *)result
{
    if(!menu)
    {
        menu = [[NSMenu alloc] initWithTitle:@"TagChimp"];
        NSMenuItem* item = [menu addItemWithTitle:@"Edit in Browser" action:@selector(edit:) keyEquivalent:@""];
        [item setTarget:self];
    }
    for(NSMenuItem* item in [menu itemArray])
        [item setRepresentedObject:result];
    return menu;
}

- (void)edit:(id)sender
{
    MZSearchResult* result = [sender representedObject];
    if([result protectedValueForKey:TagChimpIdTagIdent] != NSNotApplicableMarker)
    {
        NSString* tagChimpId = [result valueForKey:TagChimpIdTagIdent];
    
        NSString* str = [[NSString stringWithFormat:
            @"https://www.tagchimp.com/tc/%@/",
            tagChimpId] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL* url = [NSURL URLWithString:str];
        [[NSWorkspace sharedWorkspace] openURL:url];
    }
}

- (BOOL)searchWithData:(NSDictionary *)data
              delegate:(id<MZSearchProviderDelegate>)delegate
                 queue:(NSOperationQueue *)queue;
{
    NSURL* searchURL = [NSURL URLWithString:@"https://tagchimp.com/ape/search.php"];
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:TCToken forKey:@"token"];
    [params setObject:@"search" forKey:@"type"];
    
    NSArray* chapters = [data objectForKey:MZChaptersTagIdent];
    NSString* totalChapters;
    if(chapters)
        totalChapters = [[NSNumber numberWithInteger:[chapters count]] stringValue];
    else
        totalChapters = @"X";
    [params setObject:totalChapters forKey:@"totalChapters"];
    
    BOOL supportsEmptyTitle = NO;
    NSString* title = [data objectForKey:MZTitleTagIdent];
    if(!title)
        title = @"";
    [params setObject:title forKey:@"title"];

    NSNumber* videoKindObj = [data objectForKey:MZVideoTypeTagIdent];
    if(videoKindObj)
    {
        NSString* videoKind = nil;
        switch ([videoKindObj intValue]) {
            case MZMovieVideoType:
                videoKind = @"Movie";
                break;
            case MZTVShowVideoType:
                videoKind = @"TVShow";
                break;
            case MZMusicVideoType:
                videoKind = @"MusicVideo";
                break;
        }
        if(videoKind)
            [params setObject:videoKind forKey:@"videoKind"];
    }
        
    NSString* tvShow = [data objectForKey:MZTVShowTagIdent];
    if(tvShow)
    {
        [params setObject:tvShow forKey:@"show"];
        supportsEmptyTitle = YES;
    }
        
    NSNumber* season = [data objectForKey:MZTVSeasonTagIdent];
    if(season)
    {
        [params setObject:[season stringValue] forKey:@"season"];
        supportsEmptyTitle = YES;
    }

    NSNumber* episode = [data objectForKey:MZTVEpisodeTagIdent];
    if(episode)
    {
        [params setObject:[episode stringValue] forKey:@"episode"];
        supportsEmptyTitle = YES;
    }
    
    [params setObject:@"200" forKey:@"limit"];
    
    [self cancelSearch];

    if([title length] == 0 && !supportsEmptyTitle)
        return NO;

    MZLoggerDebug(@"Sent request to tagChimp:");
    for(NSString* key in [params allKeys])
        MZLoggerDebug(@"    '%@' -> '%@'", key, [params objectForKey:key]);
    TCSearch* search = [TCSearch searchWithProvider:self delegate:delegate url:searchURL parameters:params];
    [self startSearch:search];
    [search addToQueue:queue];
    return YES;
}

@end
