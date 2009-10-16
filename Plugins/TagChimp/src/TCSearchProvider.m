//
//  TCSearchProvider.m
//  MetaZ
//
//  Created by Brian Olsen on 11/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "TCSearchProvider.h"


@implementation TCSearchProvider

- (void)dealloc
{
    [search release];
    [icon release];
    [supportedSearchTags release];
    [super dealloc];
}

- (NSImage *)icon
{
    if(!icon)
    {
        NSBundle* myBundle = [NSBundle bundleForClass:[self class]];
        NSString* iconImp = [myBundle pathForResource:@"tagChimp" ofType:@"png"];
        icon = [[NSImage alloc] initWithContentsOfFile:iconImp];
    }
    return icon;
}

- (NSString *)identifier
{
    return @"org.maven-group.MetaZ.TagChimpPlugin";
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

- (BOOL)searchWithData:(NSDictionary *)data delegate:(id<MZSearchProviderDelegate>)delegate;
{
    NSURL* searchURL = [NSURL URLWithString:@"https://www.tagchimp.com/ape/search.php"];
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:@"8363185134824C8CD908AA" forKey:@"token"];
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
    
    if([title length] == 0 && !supportsEmptyTitle)
        return NO;

    if(search)
    {
        // Finish last search;
        [search cancel];
        [search release];
        search = nil;
    }
    NSLog(@"Sent request:");
    for(NSString* key in [params allKeys])
        NSLog(@"    '%@' -> '%@'", key, [params objectForKey:key]);
    MZRESTWrapper* wrapper = [[MZRESTWrapper alloc] init];
    search = [[TCSearch alloc] initWithProvider:self delegate:delegate wrapper:wrapper];
    wrapper.delegate = search;
    [wrapper sendRequestTo:searchURL usingVerb:@"GET" withParameters:params];
    return YES;
}

@end
