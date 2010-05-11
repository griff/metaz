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
        
        TheTVDBBaseSeriesLoader* seriesLoader = [[TheTVDBBaseSeriesLoader alloc] initWithSeries:series];
        [search queueOperation:seriesLoader];
        
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
        [seriesLoader release];
    }
    
    [super wrapper:theWrapper didRetrieveData:data];
}

@end


@implementation TheTVDBBaseSeriesLoader

- (id)initWithSeries:(NSUInteger)theSeries
{
    NSString* urlStr = [NSString stringWithFormat:@"%@/api/%@/series/%d/en.xml",
            @"http://www.thetvdb.com",
            THETVDB_API_KEY,
            theSeries];
    NSURL* url = [NSURL URLWithString:urlStr];
    self = [super initWithURL:url usingVerb:@"GET" parameters:nil];
    if(self)
    {
        series = theSeries;
    }
    return self;
}

@synthesize series;
@synthesize data;

#pragma mark - MZRESTWrapperDelegate

- (void)wrapper:(MZRESTWrapper *)theWrapper didRetrieveData:(NSData *)theData
{
    NSXMLDocument* doc = [theWrapper responseAsXml];
    //MZLoggerDebug(@"Got TheTVDB series response: %@", [theWrapper responseAsText]);

    NSMutableDictionary* ret = [NSMutableDictionary dictionary];

    NSString* tvShow = [doc stringForXPath:@"/Data/Series/SeriesName" error:NULL];
    MZTag* tvShowTag = [MZTag tagForIdentifier:MZTVShowTagIdent];
    [ret setObject:[tvShowTag objectFromString:tvShow] forKey:MZTVShowTagIdent];
    MZTag* artistTag = [MZTag tagForIdentifier:MZArtistTagIdent];
    [ret setObject:[artistTag objectFromString:tvShow] forKey:MZArtistTagIdent];

    NSString* tvNetwork = [doc stringForXPath:@"/Data/Series/Network" error:NULL];
    if(tvNetwork && [tvNetwork length] > 0)
    {
        MZTag* tvNetworkTag = [MZTag tagForIdentifier:MZTVNetworkTagIdent];
        [ret setObject:[tvNetworkTag objectFromString:tvNetwork] forKey:MZTVNetworkTagIdent];
    }
    
    NSString* rating = [doc stringForXPath:@"/Data/Series/ContentRating" error:NULL];
    MZTag* ratingTag = [MZTag tagForIdentifier:MZRatingTagIdent];
    NSNumber* ratingNr = [ratingTag objectFromString:rating];
    if([ratingNr intValue] != MZNoRating)
        [ret setObject:ratingNr forKey:MZRatingTagIdent];

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
        [ret setObject:[actors componentsJoinedByString:@", "] forKey:MZActorsTagIdent];
    
    
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
        [ret setObject:[genres objectAtIndex:0] forKey:MZGenreTagIdent];

    NSString* imdbId = [doc stringForXPath:@"/Data/Series/IMDB_ID" error:NULL];
    if(imdbId && [imdbId length] > 0)
    {
        MZTag* imdbTag = [MZTag tagForIdentifier:MZIMDBTagIdent];
        [ret setObject:[imdbTag objectFromString:imdbId] forKey:MZIMDBTagIdent];
    }
    self.data = ret;

    [super wrapper:theWrapper didRetrieveData:theData];
}

@end



@implementation TheTVDBEpisodeLoader

- (id)initWithProvider:(id)theProvider delegate:(id<MZSearchProviderDelegate>)theDelegate series:(TheTVDBBaseSeriesLoader *)theSeries season:(NSUInteger)theSeason episode:(NSUInteger)theEpisode
{
    return [self initWithProvider:theProvider delegate:theDelegate series:theSeries season:theSeason episode:theEpisode dvdOrder:NO];
}

- (id)initWithProvider:(id)theProvider delegate:(id<MZSearchProviderDelegate>)theDelegate series:(TheTVDBBaseSeriesLoader *)theSeries season:(NSUInteger)theSeason episode:(NSUInteger)theEpisode dvdOrder:(BOOL)dvdOrder
{
    NSString* order;
    if(dvdOrder)
        order = @"dvd";
    else
        order = @"default";
    NSString* urlStr = [NSString stringWithFormat:@"%@/api/%@/series/%d/%@/%d/%d/en.xml",
            @"http://www.thetvdb.com",
            THETVDB_API_KEY,
            theSeries.series,
            order,
            theSeason,
            theEpisode];
    NSURL* url = [NSURL URLWithString:urlStr];
    self = [super initWithProvider:theProvider delegate:theDelegate url:url usingVerb:@"GET" parameters:nil];
    if(self)
    {
        series = [theSeries retain];
        season = theSeason;
        episode = theEpisode;

        [self addDependency:series];
    }
    return self;
}

- (void)dealloc
{
    [series release];
    [super dealloc];
}

- (NSDictionary *)parse
{
    NSXMLDocument* doc = [wrapper responseAsXml];
    //MZLoggerDebug(@"Got TheTVDB episode response: %@", [wrapper responseAsText]);
    
    NSMutableDictionary* ret = [NSMutableDictionary dictionaryWithDictionary:series.data];
    
    NSString* seasonId = [doc stringForXPath:@"/Data/Episode/seasonid" error:NULL];
    NSString* episodeId = [doc stringForXPath:@"/Data/Episode/id" error:NULL];
    NSString* query = [NSString stringWithFormat:@"seriesid=%d&seasonid=%@&id=%@",
        series, seasonId, episodeId];
    [ret setObject:query forKey:EpisodeQueryTagIdent];

    NSString* title = [doc stringForXPath:@"/Data/Episode/EpisodeName" error:NULL];
    if(title && [title length] > 0)
    {
        MZTag* tag = [MZTag tagForIdentifier:MZTitleTagIdent];
        [ret setObject:[tag objectFromString:title] forKey:MZTitleTagIdent];
    }

    NSString* seasonNo = [doc stringForXPath:@"/Data/Episode/SeasonNumber" error:NULL];
    if(seasonNo && [seasonNo length] > 0)
    {
        MZTag* tag = [MZTag tagForIdentifier:MZTVSeasonTagIdent];
        [ret setObject:[tag objectFromString:seasonNo] forKey:MZTVSeasonTagIdent];
    }

    NSString* episodeNo = [doc stringForXPath:@"/Data/Episode/EpisodeNumber" error:NULL];
    if(episodeNo && [episodeNo length] > 0)
    {
        MZTag* tag = [MZTag tagForIdentifier:MZTVEpisodeTagIdent];
        [ret setObject:[tag objectFromString:episodeNo] forKey:MZTVEpisodeTagIdent];
    }

    NSString* directorStr = [doc stringForXPath:@"/Data/Episode/Director" error:NULL];
    NSArray* directors1 = [directorStr componentsSeparatedByString:@"|"];
    NSMutableArray* directors = [NSMutableArray array];
    for(NSString* str in directors1)
    {
        NSString* str2 = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if([str2 length] > 0)
            [directors addObject:str2];
    }
    if([directors count] > 0)
        [ret setObject:[directors componentsJoinedByString:@", "] forKey:MZDirectorTagIdent];

    NSString* writerStr = [doc stringForXPath:@"/Data/Episode/Writer" error:NULL];
    NSArray* writers1 = [writerStr componentsSeparatedByString:@"|"];
    NSMutableArray* writers = [NSMutableArray array];
    for(NSString* str in writers1)
    {
        NSString* str2 = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if([str2 length] > 0)
            [writers addObject:str2];
    }
    if([writers count] > 0)
        [ret setObject:[writers componentsJoinedByString:@", "] forKey:MZScreenwriterTagIdent];

    NSString* description = [doc stringForXPath:@"/Data/Episode/Overview" error:NULL];
    if(description && [description length] > 0)
    {
        [ret setObject:description forKey:MZShortDescriptionTagIdent];
        [ret setObject:description forKey:MZLongDescriptionTagIdent];
    }

    NSString* productionCode = [doc stringForXPath:@"/Data/Episode/ProductionCode" error:NULL];
    if(productionCode && [productionCode length] > 0)
    {
        MZTag* tag = [MZTag tagForIdentifier:MZTVEpisodeIDTagIdent];
        [ret setObject:[tag objectFromString:productionCode] forKey:MZTVEpisodeIDTagIdent];
    }

    NSString* release = [doc stringForXPath:@"/Data/Episode/FirstAired" error:NULL];
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
            [ret setObject:date forKey:MZDateTagIdent];
        else
            MZLoggerError(@"Unable to parse release date '%@'", release);
    }

    NSString* dvdSeasonStr = [doc stringForXPath:@"/Data/Episode/DVD_season" error:NULL];
    if(dvdSeasonStr && [dvdSeasonStr length] > 0)
    {
        MZTag* dvdSeasonTag = [MZTag tagForIdentifier:MZDVDSeasonTagIdent];
        [ret setObject:[dvdSeasonTag objectFromString:dvdSeasonStr] forKey:MZDVDSeasonTagIdent];
    }

    NSString* dvdEpisodeStr = [doc stringForXPath:@"/Data/Episode/DVD_episodenumber" error:NULL];
    if(dvdEpisodeStr && [dvdEpisodeStr length] > 0)
    {
        MZTag* dvdEpisodeTag = [MZTag tagForIdentifier:MZDVDEpisodeTagIdent];
        [ret setObject:[dvdEpisodeTag objectFromString:dvdEpisodeStr] forKey:MZDVDEpisodeTagIdent];
    }

    NSString* imdbId = [doc stringForXPath:@"/Data/Episode/IMDB_ID" error:NULL];
    if(imdbId && [imdbId length] > 0)
    {
        MZTag* imdbTag = [MZTag tagForIdentifier:MZIMDBTagIdent];
        [ret setObject:[imdbTag objectFromString:imdbId] forKey:MZIMDBTagIdent];
    }
    
    return ret;
}

- (NSArray *)parseResult
{
    return [NSArray arrayWithObject:[MZSearchResult resultWithOwner:provider dictionary:[self parse]]];
}

@end


@implementation TheTVDBEpisodeFinder

- (id)initWithSearch:(TheTVDBSearch*)theSearch series:(TheTVDBBaseSeriesLoader *)theSeries season:(NSUInteger)theSeason episode:(NSUInteger)theEpisode
{
    self = [super initWithProvider:theSearch.provider delegate:theSearch.delegate series:theSeries season:theSeason episode:theEpisode];
    if(self)
    {
        search = theSearch;
    }
    return self;
}

- (void)operationFinished
{
    if(self->search)
        MZLoggerDebug(@"Operation finished ");
}

- (NSDictionary *)parse
{
    NSDictionary *result = [super parse];
    NSNumber* dvdEpisode = [result objectForKey:@"dvdEpisode"];
    if(dvdEpisode && [dvdEpisode integerValue] != episode)
    {
        TheTVDBEpisodeLoader* loader = [[TheTVDBEpisodeLoader alloc]
            initWithProvider:provider
                    delegate:delegate
                      series:series
                      season:season
                     episode:episode
                    dvdOrder:YES];
        [search queueOperation:loader];
        [loader release];
    }
    return result;
}

@end


@implementation TheTVDBSeasonFinder

- (id)initWithSearch:(TheTVDBSearch*)theSearch series:(TheTVDBBaseSeriesLoader *)theSeries season:(NSUInteger)theSeason episode:(NSUInteger)theEpisode lowerBound:(NSInteger)lBound upperBound:(NSInteger)uBound
{
    self = [super initWithProvider:theSearch.provider delegate:theSearch.delegate series:theSeries season:theSeason episode:theEpisode];
    if(self)
    {
        search = theSearch;
        lowestFoundNo = lBound;
        highestTriedNo = uBound;
    }
    return self;
}

- (id)initWithSearch:(TheTVDBSearch*)theSearch series:(TheTVDBBaseSeriesLoader *)theSeries season:(NSUInteger)theSeason;
{
    return [self initWithSearch:theSearch series:theSeries season:theSeason episode:20 lowerBound:0 upperBound:-1];
}

- (void)operationFinished
{
    if(self->search)
        MZLoggerDebug(@"Operation finished ");
}


- (NSDictionary *)parse
{
    NSDictionary *result = [super parse];
    //MZLoggerDebug(@"Got TheTVDB season finder response: %@", [wrapper responseAsText]);
    if(lowestFoundNo < episode-1)
    {
        // Load from lowest to current
        for(int i=lowestFoundNo+1; i<episode; i++)
        {
            TheTVDBEpisodeLoader* loader = [[TheTVDBEpisodeLoader alloc]
                initWithProvider:provider
                        delegate:delegate
                          series:series
                          season:season
                          episode:i];
            [search queueOperation:loader];
            [loader release];
        }
    }
    if(highestTriedNo==-1)
    {
        NSUInteger next = episode*2;
        TheTVDBSeasonFinder* nextFinder = [[TheTVDBSeasonFinder alloc]
            initWithSearch:search
                    series:series
                    season:season
                   episode:next
                lowerBound:episode
                upperBound:-1];
        
        [search queueOperation:nextFinder];
        [nextFinder release];
    }
    else if(episode+1 != highestTriedNo)
    {
        NSUInteger next = episode + (highestTriedNo-episode)/2;
        TheTVDBSeasonFinder* nextFinder = [[TheTVDBSeasonFinder alloc]
            initWithSearch:search
                    series:series
                    season:season
                   episode:next
                lowerBound:episode
                upperBound:highestTriedNo];
        [search queueOperation:nextFinder];
        [nextFinder release];
    }

    return result;
}

- (void)wrapper:(MZRESTWrapper *)theWrapper didReceiveStatusCode:(int)statusCode
{
    if(statusCode == 404)
    {
        if(lowestFoundNo+1<episode)
        {
            NSUInteger next = lowestFoundNo + (episode - lowestFoundNo)/2;
            TheTVDBSeasonFinder* nextFinder = [[TheTVDBSeasonFinder alloc]
                initWithSearch:search
                        series:series
                        season:season
                       episode:next
                    lowerBound:lowestFoundNo
                    upperBound:episode];
            [search queueOperation:nextFinder];
            [nextFinder release];
        }
    }
    [super wrapper:theWrapper didReceiveStatusCode:statusCode];
}

@end


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


