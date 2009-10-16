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
        /*
        MZRating ratings[] = { MZNoRating,
            //US
            MZ_G_Rating, MZ_PG_Rating, MZ_PG13_Rating, MZ_R_Rating, MZ_NC17_Rating, MZ_Unrated_Rating,
            //US-TV
            MZ_TVY7_Rating, MZ_TVY_Rating, MZ_TVG_Rating, MZ_TVPG_Rating, MZ_TV14_Rating, MZ_TVMA_Rating,
            // UK
            MZ_U_Rating, MZ_Uc_Rating, MZ_PG_UK_Rating, MZ_12_UK_Rating, MZ_12A_Rating, MZ_15_UK_Rating, MZ_18_UK_Rating, MZ_E_UK_Rating, MZ_Unrated_UK_Rating,
            // DE
            MZ_FSK0_Rating, MZ_FSK6_Rating, MZ_FSK12_Rating, MZ_FSK16_Rating, MZ_FSK18_Rating,
            // IE
            MZ_G_IE_Rating, MZ_PG_IE_Rating, MZ_12_IE_Rating, MZ_15_IE_Rating, MZ_16_Rating, MZ_18_IE_Rating, MZ_Unrated_IE_Rating,
            // IE-TV
            MZ_GA_Rating, MZ_Ch_Rating, MZ_YA_Rating, MZ_PS_Rating, MZ_MA_IETV_Rating, MZ_Unrated_IETV_Rating,
            // CA
            MZ_G_CA_Rating, MZ_PG_CA_Rating, MZ_14_Rating, MZ_18_CA_Rating, MZ_R_CA_Rating, MZ_E_CA_Rating, MZ_Unrated_CA_Rating,
            // CA-TV
            MZ_C_CATV_Rating, MZ_C8_Rating, MZ_G_CATV_Rating, MZ_PG_CATV_Rating, MZ_14Plus_Rating, MZ_18Plus_Rating, MZ_Unrated_CATV_Rating,
            // AU
            MZ_E_AU_Rating, MZ_G_AU_Rating, MZ_PG_AU_Rating, MZ_M_AU_Rating, MZ_MA15Plus_AU_Rating, MZ_R18Plus_Rating, MZ_Unrated_AU_Rating,
            // AU-TV
            MZ_P_Rating, MZ_C_AUTV_Rating, MZ_G_AUTV_Rating, MZ_PG_AUTV_Rating, MZ_M_AUTV_Rating, MZ_MA15Plus_AUTV_Rating, MZ_AV15Plus_Rating, MZ_Unrated_AUTV_Rating,    
            // NZ
            MZ_E_NZ_Rating, MZ_G_NZ_Rating, MZ_PG_NZ_Rating, MZ_M_NZ_Rating, MZ_R13_Rating, MZ_R15_Rating, MZ_R16_Rating, MZ_R18_Rating, MZ_R_NZ_Rating, MZ_Unrated_NZ_Rating,
            // NZ-TV
            MZ_G_NZTV_Rating, MZ_PGR_Rating, MZ_AO_Rating, MZ_Unrated_NZTV_Rating,
        };
        */
        ratingNames = [[NSArray alloc] initWithObjects:
            @"No Rating",
            // US
            @"G", @"PG", @"PG-13", @"R", @"NC-17", @"Unrated",
            // US TV
            @"TV-V7", @"TV-Y", @"TV-G", @"TV-PG", @"TV-14", @"TV-MA",
            // UK
            @"U", @"Uc", @"PG (UK)", @"12 (UK)", @"12A", @"15 (UK)", @"18 (UK)", @"E (UK)", @"UNRATED (UK)",
            // DE
            @"FSK-0", @"FSK-6", @"FSK-12", @"FSK-16", @"FSK-18",
            // IE
            @"G (IE)", @"PG (IE)", @"12 (IE)", @"15 (IE)", @"16", @"18 (IE)", @"UNRATED (IE)",
            // IE TV
            @"GA", @"Ch", @"YA", @"PS", @"MA (IE-TV)", @"UNRATED (IE-TV)",
            // CA
            @"G (CA)", @"PG (CA)", @"14", @"18 (CA)", @"R (CA)", @"E (CA)", @"UNRATED (CA)",
            // CA-TV
            @"C (CA-TV)", @"C8", @"G (CA-TV)", @"PG (CA-TV)", @"14+", @"18+", @"UNRATED (CA-TV)",
            // AU
            @"E (AU)", @"G (AU)", @"PG (AU)", @"M (AU)", @"MA 15+", @"R 18+", @"UNRATED (AU)",
            // AU TV
            @"P", @"C (AU-TV)", @"G (AU-TV)", @"PG (AU-TV)", @"M (AU-TV)", @"MA 15+ (AU-TV)", @"AV 15+", @"UNRATED (AU-TV)",
            // NZ
            @"E (NZ)", @"G (NZ)", @"PG (NZ)", @"M (NZ)", @"R13", @"R15", @"R16",
            @"R18", @"R (NZ)", @"UNRATED (NZ)",
            // NZ TV
            @"G (NZ-TV)", @"PGR", @"AD", @"UNRATED (NZ-TV)",
            nil];
        NSAssert([ratingNames count] == MZ_Unrated_NZTV_Rating+1, @"Bad number of ratings");
    }
    return self;
}

- (void)dealloc
{
    [wrapper cancelConnection];
    [wrapper release];
    [delegate release];
    [mapping release];
    [ratingNames release];
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
    NSLog(@"Got results %d", [items count]);
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
        
        NSString* rating = [[[item nodesForXPath:@"movieTags/info/rating" error:NULL]
            arrayByPerformingSelector:@selector(stringValue)]
                componentsJoinedByString:@", "];
        NSInteger ratingNr = [ratingNames indexOfObject:rating];
        if(ratingNr != NSNotFound)
        {
            [dict setObject:[NSNumber numberWithInt:ratingNr] forKey:MZRatingTagIdent];
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
    NSLog(@"Parsed results %d", [results count]);
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
    [delegate searchFinished];
}


@end
