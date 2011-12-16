//
//  TheTVDBSearch.m
//  MetaZ
//
//  Created by Nigel Graham on 10/04/10.
//  Copyright 2010 Maven-Group. All rights reserved.
//

#import "TheTVDBSearch.h"
#import "Access.h"
#import "TheTVDBPlugin.h"


@implementation TheTVDBSearch

+ (id)searchWithProvider:(id)provider delegate:(id<MZSearchProviderDelegate>)delegate queue:(NSOperationQueue *)queue
{
    return [[[self alloc] initWithProvider:provider delegate:delegate queue:queue] autorelease];
}

- (id)initWithProvider:(id)theProvider delegate:(id<MZSearchProviderDelegate>)theDelegate queue:(NSOperationQueue *)theQueue
{
    self = [super init];
    if(self)
    {
        provider = theProvider;
        delegate = [theDelegate retain];
        queue = [theQueue retain];
    }
    return self;
}

- (void)dealloc
{
    [delegate release];
    [queue release];
    [super dealloc];
}

@synthesize provider;
@synthesize delegate;

- (void)queueOperation:(NSOperation *)operation
{
    @synchronized(self)
    {
        [self addOperation:operation];
        [queue addOperation:operation];
    }
}

- (void)operationsFinished
{
    [delegate searchFinished];
}

@end


@implementation TheTVDBUpdateMirrors

+(NSString *)findMirror
{
    return nil;
}

- (id)init
{
    NSURL* url = [NSURL URLWithString:[NSString
            stringWithFormat:@"http://www.thetvdb.com/api/%@/mirrors.xml",
                THETVDB_API_KEY]];
    return [super initWithURL:url usingVerb:@"GET" parameters:nil];
}

#pragma mark - MZRESTWrapperDelegate

- (void)wrapper:(MZRESTWrapper *)theWrapper didRetrieveData:(NSData *)data
{
    [super wrapper:theWrapper didRetrieveData:data];
}

@end


@implementation TheTVDBGetSeries

- (id)initWithSearch:(TheTVDBSearch*)theSearch name:(NSString *)name season:(NSUInteger)theSeason episode:(NSInteger)theEpisode;
{
    NSURL* url = [NSURL URLWithString:@"http://www.thetvdb.com/api/GetSeries.php"];
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:name, @"seriesname", @"en", @"language", nil];
    self = [super initWithURL:url usingVerb:@"GET" parameters:params];
    if(self)
    {
        search = theSearch;
        season = theSeason;
        episode = theEpisode;
    }
    return self;
}

- (void)operationFinished
{
    if(self->search)
        MZLoggerDebug(@"Operation finished ");
}

#pragma mark - MZRESTWrapperDelegate

- (void)wrapper:(MZRESTWrapper *)theWrapper didRetrieveData:(NSData *)data
{
    NSXMLDocument* doc = [theWrapper responseAsXml];
    //MZLoggerDebug(@"Got TheTVDB response: %@", [theWrapper responseAsText]);

    NSArray* items = [doc nodesForXPath:@"/Data/Series" error:NULL];
    MZLoggerDebug(@"Got TheTVDB series %d", [items count]);
    for(NSXMLElement* item in items)
    {
        NSString* seriesStr = [item stringForXPath:@"seriesid" error:NULL];
        NSUInteger series = [seriesStr integerValue];

        TheTVDBFullSeriesLoader* seriesLoader = 
            [[TheTVDBFullSeriesLoader alloc] initWithProvider:search.provider 
                delegate:search.delegate
                series:series
                season:season
                episode:episode];
        
        
        //TheTVDBBaseSeriesLoader* seriesLoader = [[TheTVDBBaseSeriesLoader alloc] initWithSeries:series];
        [search queueOperation:seriesLoader];
        /*
        if(episode != -1)
        {
            TheTVDBEpisodeFinder* finder = [[TheTVDBEpisodeFinder alloc] initWithSearch:search series:seriesLoader season:season episode:episode];
            [search queueOperation:finder];
            [finder release];
        }
        else
        {
            TheTVDBSeasonFinder* finder = [[TheTVDBSeasonFinder alloc] initWithSearch:search series:seriesLoader season:season];
            [search queueOperation:finder];
            [finder release];
        }
        */
        [seriesLoader release];
    }
    
    [super wrapper:theWrapper didRetrieveData:data];
}

@end


@implementation TheTVDBFullSeriesLoader
@synthesize series;
@synthesize season;
@synthesize episode;

- (id)initWithProvider:(id)theProvider delegate:(id<MZSearchProviderDelegate>)theDelegate series:(NSUInteger)theSeries season:(NSUInteger)theSeason episode:(NSInteger)theEpisode;
{
    NSString* urlStr = [NSString stringWithFormat:@"%@/api/%@/series/%d/all/en.xml",
            @"http://www.thetvdb.com",
            THETVDB_API_KEY,
            theSeries];
    NSURL* url = [NSURL URLWithString:urlStr];
    self = [super initWithProvider:theProvider delegate:theDelegate url:url usingVerb:@"GET" parameters:nil];
    if(self)
    {
        series = theSeries;
        season = theSeason;
        episode = theEpisode;
    }
    return self;
}

#pragma mark - MZRESTWrapperDelegate

- (void)wrapper:(MZRESTWrapper *)theWrapper didRetrieveData:(NSData *)data
{
    NSXMLDocument* doc = [theWrapper responseAsXml];

    NSMutableDictionary* seriesDict = [NSMutableDictionary dictionary];

    NSString* tvShow = [doc stringForXPath:@"/Data/Series/SeriesName" error:NULL];
    MZTag* tvShowTag = [MZTag tagForIdentifier:MZTVShowTagIdent];
    [seriesDict setObject:[tvShowTag objectFromString:tvShow] forKey:MZTVShowTagIdent];
    MZTag* artistTag = [MZTag tagForIdentifier:MZArtistTagIdent];
    [seriesDict setObject:[artistTag objectFromString:tvShow] forKey:MZArtistTagIdent];

    NSString* tvNetwork = [doc stringForXPath:@"/Data/Series/Network" error:NULL];
    if(tvNetwork && [tvNetwork length] > 0)
    {
        MZTag* tvNetworkTag = [MZTag tagForIdentifier:MZTVNetworkTagIdent];
        [seriesDict setObject:[tvNetworkTag objectFromString:tvNetwork] forKey:MZTVNetworkTagIdent];
    }
    
    NSString* rating = [doc stringForXPath:@"/Data/Series/ContentRating" error:NULL];
    MZTag* ratingTag = [MZTag tagForIdentifier:MZRatingTagIdent];
    NSNumber* ratingNr = [ratingTag objectFromString:rating];
    if([ratingNr intValue] != MZNoRating)
        [seriesDict setObject:ratingNr forKey:MZRatingTagIdent];

    NSString* actorStr = [doc stringForXPath:@"/Data/Series/Actors" error:NULL];
    NSArray* actors1 = [actorStr componentsSeparatedByString:@"|"];
    NSMutableArray* actors = [NSMutableArray array];
    for(NSString* str in actors1)
    {
        NSString* str2 = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if([str2 length] > 0)
            [actors addObject:str2];
    }
    if([actors count] > 0)
        [seriesDict setObject:[actors componentsJoinedByString:@", "] forKey:MZActorsTagIdent];
    
    
    NSString* genreStr = [doc stringForXPath:@"/Data/Series/Genre" error:NULL];
    NSArray* genres1 = [genreStr componentsSeparatedByString:@"|"];
    NSMutableArray* genres = [NSMutableArray array];
    for(NSString* str in genres1)
    {
        NSString* str2 = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if([str2 length] > 0)
            [genres addObject:str2];
    }
    if([genres count] > 0)
        [seriesDict setObject:[genres objectAtIndex:0] forKey:MZGenreTagIdent];

    NSString* imdbId = [doc stringForXPath:@"/Data/Series/IMDB_ID" error:NULL];
    if(imdbId && [imdbId length] > 0)
    {
        MZTag* imdbTag = [MZTag tagForIdentifier:MZIMDBTagIdent];
        [seriesDict setObject:[imdbTag objectFromString:imdbId] forKey:MZIMDBTagIdent];
    }
    
    
    NSMutableArray* results = [NSMutableArray array];

    NSArray* items = [doc nodesForXPath:@"/Data/Episode" error:NULL];
    MZLoggerDebug(@"Got TheTVDB series %d", [items count]);
    for(NSXMLElement* item in items)
    {
        NSString* seasonNo = [item stringForXPath:@"SeasonNumber" error:NULL];
        if([seasonNo integerValue] != season)
            continue;
            
        NSString* episodeNo = [item stringForXPath:@"EpisodeNumber" error:NULL];
        if(episode>=0 && [episodeNo integerValue] != episode)
            continue;


        NSMutableDictionary* episodeDict = [NSMutableDictionary dictionaryWithDictionary:seriesDict];
    
        if(seasonNo && [seasonNo length] > 0)
        {
            MZTag* tag = [MZTag tagForIdentifier:MZTVSeasonTagIdent];
            [episodeDict setObject:[tag objectFromString:seasonNo] forKey:MZTVSeasonTagIdent];
        }

        if(episodeNo && [episodeNo length] > 0)
        {
            MZTag* tag = [MZTag tagForIdentifier:MZTVEpisodeTagIdent];
            [episodeDict setObject:[tag objectFromString:episodeNo] forKey:MZTVEpisodeTagIdent];
        }

        [episodeDict setObject:[NSNumber numberWithUnsignedInt:series] forKey:TVDBSeriesIdTagIdent];
        NSString* seasonId = [item stringForXPath:@"seasonid" error:NULL];
        [episodeDict setObject:seasonId forKey:TVDBSeasonIdTagIdent];
        NSString* episodeId = [item stringForXPath:@"id" error:NULL];
        [episodeDict setObject:episodeId forKey:TVDBEpisodeIdTagIdent];

        NSString* title = [item stringForXPath:@"EpisodeName" error:NULL];
        if(title && [title length] > 0)
        {
            MZTag* tag = [MZTag tagForIdentifier:MZTitleTagIdent];
            [episodeDict setObject:[tag objectFromString:title] forKey:MZTitleTagIdent];
        }

        NSString* directorStr = [item stringForXPath:@"Director" error:NULL];
        NSArray* directors1 = [directorStr componentsSeparatedByString:@"|"];
        NSMutableArray* directors = [NSMutableArray array];
        for(NSString* str in directors1)
        {
            NSString* str2 = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if([str2 length] > 0)
                [directors addObject:str2];
        }
        if([directors count] > 0)
            [episodeDict setObject:[directors componentsJoinedByString:@", "] forKey:MZDirectorTagIdent];

        NSString* writerStr = [item stringForXPath:@"Writer" error:NULL];
        NSArray* writers1 = [writerStr componentsSeparatedByString:@"|"];
        NSMutableArray* writers = [NSMutableArray array];
        for(NSString* str in writers1)
        {
            NSString* str2 = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if([str2 length] > 0)
                [writers addObject:str2];
        }
        if([writers count] > 0)
            [episodeDict setObject:[writers componentsJoinedByString:@", "] forKey:MZScreenwriterTagIdent];

        NSString* description = [item stringForXPath:@"Overview" error:NULL];
        if(description && [description length] > 0)
        {
            [episodeDict setObject:description forKey:MZShortDescriptionTagIdent];
            [episodeDict setObject:description forKey:MZLongDescriptionTagIdent];
        }

        NSString* productionCode = [item stringForXPath:@"ProductionCode" error:NULL];
        if(productionCode && [productionCode length] > 0)
        {
            MZTag* tag = [MZTag tagForIdentifier:MZTVEpisodeIDTagIdent];
            [episodeDict setObject:[tag objectFromString:productionCode] forKey:MZTVEpisodeIDTagIdent];
        }

        NSString* release = [item stringForXPath:@"FirstAired" error:NULL];
        if( release && [release length] > 0 )
        {
            NSDate* date;// = [NSDate dateWithUTCString:release];
            //if(!date)
            {
                NSDateFormatter* format = [[[NSDateFormatter alloc] init] autorelease];
                format.dateFormat = @"yyyy-MM-dd";
                date = [format dateFromString:release];
            }
            if(date) 
                [episodeDict setObject:date forKey:MZDateTagIdent];
            else
                MZLoggerError(@"Unable to parse release date '%@'", release);
        }

        NSString* dvdSeasonStr = [item stringForXPath:@"DVD_season" error:NULL];
        if(dvdSeasonStr && [dvdSeasonStr length] > 0)
        {
            MZTag* dvdSeasonTag = [MZTag tagForIdentifier:MZDVDSeasonTagIdent];
            [episodeDict setObject:[dvdSeasonTag objectFromString:dvdSeasonStr] forKey:MZDVDSeasonTagIdent];
        }

        NSString* dvdEpisodeStr = [item stringForXPath:@"DVD_episodenumber" error:NULL];
        if(dvdEpisodeStr && [dvdEpisodeStr length] > 0)
        {
            MZTag* dvdEpisodeTag = [MZTag tagForIdentifier:MZDVDEpisodeTagIdent];
            [episodeDict setObject:[dvdEpisodeTag objectFromString:dvdEpisodeStr] forKey:MZDVDEpisodeTagIdent];
        }

        NSString* imdbId = [item stringForXPath:@"IMDB_ID" error:NULL];
        if(imdbId && [imdbId length] > 0)
        {
            MZTag* imdbTag = [MZTag tagForIdentifier:MZIMDBTagIdent];
            [episodeDict setObject:[imdbTag objectFromString:imdbId] forKey:MZIMDBTagIdent];
        }
        
        
        MZSearchResult* result = [MZSearchResult resultWithOwner:provider dictionary:episodeDict];
        [results addObject:result];
    }
    
    MZLoggerDebug(@"Parsed TheTVDB results %d", [results count]);
    [delegate searchProvider:provider result:results];
    [super wrapper:theWrapper didRetrieveData:data];
}

@end


