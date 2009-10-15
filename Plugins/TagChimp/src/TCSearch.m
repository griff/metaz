//
//  TCSearch.m
//  MetaZ
//
//  Created by Brian Olsen on 13/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "TCSearch.h"
#import "TagChimpPlugin.h"
#import <MetaZKit/MetaZKit.h>

@implementation TCSearch

- (id)initWithProvider:(id)theProvider delegate:(id<MZSearchProviderDelegate>)theDelegate wrapper:(MZRESTWrapper *)theWrapper
{
    self = [super init];
    if(self)
    {
        provider = [theProvider retain];
        delegate = [theDelegate retain];
        wrapper = [theWrapper retain];
        NSArray* tags = [NSArray arrayWithObjects:
            MZTitleTagIdent, MZGenreTagIdent,
            MZDirectorTagIdent, MZProducerTagIdent,
            MZScreenwriterTagIdent, MZActorsTagIdent,
            MZShortDescriptionTagIdent, MZLongDescriptionTagIdent,
            MZAdvisoryTagIdent, MZCopyrightTagIdent,
            MZCommentTagIdent, MZArtistTagIdent,
            MZTVShowTagIdent, MZTVSeasonTagIdent,
            MZTVEpisodeTagIdent, MZTVNetworkTagIdent,
            MZSortTitleTagIdent, MZSortAlbumArtistTagIdent,
            MZSortAlbumTagIdent, MZSortTVShowTagIdent,
            TagChimpIdTagIdent,
            nil];
        NSArray* keys = [NSArray arrayWithObjects:
            @"movieTags/info/movieTitle", @"movieTags/info/genre", 
            @"movieTags/info/directors/director", @"movieTags/info/producers/producer",
            @"movieTags/info/screenwriters/screenwriter", @"movieTags/info/cast/actor",
            @"movieTags/info/shortDescription", @"movieTags/info/longDescription",
            @"movieTags/info/advisory", @"movieTags/info/copyright",
            @"movieTags/info/comments", @"movieTags/info/artist/artistName",
            @"movieTags/television/showName", @"movieTags/television/season",
            @"movieTags/television/episode", @"movieTags/television/network",
            @"movieTags/sorting/name", @"movieTags/sorting/albumArtist",
            @"movieTags/sorting/album", @"movieTags/sorting/show",
            @"tagChimpID",
            nil];
        mapping = [[NSDictionary alloc] initWithObjects:tags forKeys:keys];
    }
    return self;
}

- (void)dealloc
{
    [wrapper cancelConnection];
    [wrapper release];
    [delegate release];
    [mapping release];
    [super dealloc];
}

- (void)cancel
{
    canceled = YES;
    [wrapper cancelConnection];
}

#pragma mark - MZRESTWrapperDelegate

- (void)wrapper:(MZRESTWrapper *)theWrapper didRetrieveData:(NSData *)data
{
    if(canceled)
        return;
    //NSLog(@"Got response:\n%@", [theWrapper responseAsText]);
    NSXMLDocument* doc = [theWrapper responseAsXml];
    NSArray* items = [doc nodesForXPath:@"/items/movie" error:NULL];
    NSMutableArray* results = [NSMutableArray array];
    for(NSXMLElement* item in items)
    {
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        for(NSString* xpath in [mapping allKeys])
        {
            NSString* tagId = [mapping objectForKey:xpath];
            MZTag* tag = [MZTag tagForIdentifier:tagId];
            NSArray* nodes = [item nodesForXPath:xpath error:NULL];
            NSString* value = [[nodes arrayByPerformingSelector:@selector(stringValue)]
                componentsJoinedByString:@", "];
            id obj = [tag objectFromString:value];
            if(obj)
                [dict setObject:obj forKey:tagId];
        }
        
        NSString* tagChimpId = [dict objectForKey:TagChimpIdTagIdent];
        
        NSString* videoKind = [[[item nodesForXPath:@"movieTags/info/kind" error:NULL]
            arrayByPerformingSelector:@selector(stringValue)]
                componentsJoinedByString:@", "];
        if([videoKind length] > 0)
        {
            MZTag* tag = [MZTag tagForIdentifier:MZVideoTypeTagIdent];
            MZVideoType type = MZUnsetVideoType;
            if([videoKind isEqual:@"Movie"])
                type = MZMovieVideoType;
            else if([videoKind isEqual:@"TV Show"])
                type = MZTVShowVideoType;
            else if([videoKind isEqual:@"Music Video"])
                type = MZMusicVideoType;
            if(type != MZUnsetVideoType)
            {
                id obj = [tag convertValueToObject:&type];
                if(obj)
                    [dict setObject:obj forKey:MZVideoTypeTagIdent];
            }
        }
        
        NSString* episodeId = [[[item nodesForXPath:@"movieTags/television/productionCode" error:NULL]
            arrayByPerformingSelector:@selector(stringValue)]
                componentsJoinedByString:@", "];
        if([episodeId length] == 0)
        {
            episodeId = [[[item nodesForXPath:@"movieTags/television/episodeID" error:NULL]
                arrayByPerformingSelector:@selector(stringValue)]
                    componentsJoinedByString:@", "];
        }
        if([episodeId length] > 0)
        {
            MZTag* tag = [MZTag tagForIdentifier:MZTVEpisodeIDTagIdent];
            [dict setObject:[tag objectFromString:episodeId] forKey:MZTVEpisodeIDTagIdent];
        }
        
        NSInteger totalChapters = [[[[item nodesForXPath:@"movieChapters/totalChapters" error:NULL]
                arrayByPerformingSelector:@selector(stringValue)]
                    componentsJoinedByString:@", "] integerValue];
        if(totalChapters>0)
        {
            NSArray* numbers = [[item nodesForXPath:@"movieChapters/chapter/chapterNumber" error:NULL]
                arrayByPerformingSelector:@selector(stringValue)];
            NSArray* titles = [[item nodesForXPath:@"movieChapters/chapter/chapterTitle" error:NULL]
                arrayByPerformingSelector:@selector(stringValue)];
            NSArray* times = [[item nodesForXPath:@"movieChapters/chapter/chapterTime" error:NULL]
                arrayByPerformingSelector:@selector(stringValue)];
            NSAssert1([numbers count] == totalChapters, @"chapter numbers do not match total chapter count in tagChimp entry %@", tagChimpId);
            NSAssert1([titles count] == totalChapters, @"chapter titles do not match total chapter count in tagChimp entry %@", tagChimpId);
            NSAssert1([times count] == totalChapters, @"chapter times do not match total chapter count in tagChimp entry %@", tagChimpId);
            
            NSMutableDictionary* chapterDict = [NSMutableDictionary dictionary];
            MZTimeCode* start = [MZTimeCode timeCodeWithMillis:0];
            BOOL hasTime = YES;
            for(NSInteger i=0; i<totalChapters; i++)
            {
                NSInteger number = [[numbers objectAtIndex:i] integerValue];
                NSString* title = [titles objectAtIndex:i];
                NSString* time = [times objectAtIndex:i];
                
                MZTimeCode* timeCode = [MZTimeCode timeCodeWithString:time];
                
                // Assumes timeCode is duration
                hasTime = hasTime && [timeCode millis]>0;

                MZTimedTextItem* text = [MZTimedTextItem textItemWithStart:start duration:timeCode text:title];
                [chapterDict setObject:text forKey:[NSNumber numberWithInteger:number]];
                start = [start addTimeCode:timeCode];
            }
            NSMutableArray* chapters = [NSMutableArray array];
            NSInteger i=0;
            for(NSNumber* idx in [[chapterDict allKeys] sortedArrayUsingSelector:@selector(compare:)])
            {
                NSInteger number = [idx integerValue];
                NSAssert1(number==i+1,@"Weird chapter number in tagChimp entry %@", tagChimpId);
                MZTimedTextItem* text = [chapterDict objectForKey:idx];
                if(hasTime)
                    [chapters addObject:text];
                else
                    [chapters addObject:[text text]];
                i++;
            }
            NSString* key = hasTime ? MZChaptersTagIdent : MZChapterNamesTagIdent;
            [dict setObject:[NSArray arrayWithArray:chapters] forKey:key];
        }
        
        MZSearchResult* result = [MZSearchResult resultWithOwner:provider dictionary:dict];
        [results addObject:result];
    }
    [delegate searchProvider:provider result:results];
    [delegate searchFinished];
}

- (void)wrapper:(MZRESTWrapper *)theWrapper didFailWithError:(NSError *)error
{
    if(canceled)
        return;
    NSLog(@"TagChimp search failed: %@", [error localizedDescription]);
    [delegate searchFinished];
}

- (void)wrapper:(MZRESTWrapper *)theWrapper didReceiveStatusCode:(int)statusCode
{
    NSLog(@"TagChimp got status code: %d", statusCode);
}


@end
