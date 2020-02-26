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
#import <MetaZKit/MetaZKit-Swift.h>

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
    [mirrorRequest release];
    [super dealloc];
}

@synthesize provider;
@synthesize delegate;
@synthesize season;
@synthesize episode;

- (void)cancel
{
    [delegate searchFinished];
    [delegate release];
    delegate = nil;
    [super cancel];
}

- (void)queueOperation:(NSOperation *)operation
{
    [self addOperation:operation];
    [queue addOperation:operation];
}

- (void)operationsFinished
{
    [delegate searchFinished];
}

- (void)updateMirror;
{
    NSURL* url = [NSURL URLWithString:[NSString
            stringWithFormat:@"https://www.thetvdb.com/api/%@/mirrors.xml",
                THETVDB_API_KEY]];
    //MZLoggerDebug(@"Sending request to %@", [url absoluteString]);
    mirrorRequest = [[MZHTTPRequest alloc] initWithURL:url];
    mirrorRequest.cacheStoragePolicy = ASICachePermanentlyCacheStoragePolicy;
    [mirrorRequest setDelegate:self];
    mirrorRequest.didFinishBackgroundSelector = @selector(updateMirrorCompleted:);
    mirrorRequest.didFailSelector = @selector(updateMirrorFailed:);

    [self addOperation:mirrorRequest];
}

- (void)updateMirrorCompleted:(id)request;
{
    ASIHTTPRequest* theRequest = request;
    int status = [theRequest responseStatusCode];
    if(status >= 400) {
        [self updateMirrorFailed:request];
        return;
    }
    
    //MZLoggerDebug(@"Got response from cache %@", [theRequest didUseCachedResponse] ? @"YES" : @"NO");
    NSXMLDocument* doc = [[[NSXMLDocument alloc] initWithData:[theRequest responseData] options:0 error:NULL] autorelease];
    
    NSMutableArray* bannermirrors = [NSMutableArray array]; 
    NSMutableArray* xmlmirrors = [NSMutableArray array]; 
 
    NSArray* items = [doc nodesForXPath:@"/Mirrors/Mirror" error:NULL];
    for(NSXMLElement* item in items)
    {
        NSInteger typemask = [[item stringForXPath:@"typemask" error:NULL] integerValue];
        NSString* mirrorpath = [item stringForXPath:@"mirrorpath" error:NULL];
        if((typemask & 1) == 1)
            [xmlmirrors addObject:mirrorpath];
        if((typemask & 2) == 2)
            [bannermirrors addObject:mirrorpath];
    }
    
    srandom(time(NULL));
    if([bannermirrors count] == 0)
        bannerMirror = @"https://www.thetvdb.com";
    else if([bannermirrors count] == 1)
        bannerMirror = [[bannermirrors objectAtIndex:0] retain];
    else {
        int idx = random() % [bannermirrors count];
        bannerMirror = [[bannermirrors objectAtIndex:idx] retain];
    }
    
    if([xmlmirrors count] == 0)
        xmlMirror = @"https://www.thetvdb.com";
    else if([xmlmirrors count] == 1)
        xmlMirror = [[xmlmirrors objectAtIndex:0] retain];
    else {
        int idx = random() % [xmlmirrors count];
        xmlMirror = [[xmlmirrors objectAtIndex:idx] retain];
    }
}

- (void)updateMirrorFailed:(id)request;
{
    //ASIHTTPRequest* theRequest = request;
    //MZLoggerDebug(@"Request failed with status code %d", [theRequest responseStatusCode]);

    bannerMirror = @"https://www.thetvdb.com";
    xmlMirror = @"https://www.thetvdb.com";
}


- (void)fetchSeriesByName:(NSString *)name
{
    NSString* url = @"https://www.thetvdb.com/api/GetSeries.php";
    NSDictionary* p = [NSDictionary dictionaryWithObjectsAndKeys:name, @"seriesname", @"en", @"language", nil];

    NSString* params = [NSString mz_queryStringForParameterDictionary:p];
    NSString *urlWithParams = [url stringByAppendingFormat:@"?%@", params];
    
    //MZLoggerDebug(@"Sending request to %@", urlWithParams);
    MZHTTPRequest* request = [[MZHTTPRequest alloc] initWithURL:[NSURL URLWithString:urlWithParams]];
    [request setDelegate:self];
    request.didFinishBackgroundSelector = @selector(fetchSeriesCompleted:);
    request.didFailSelector = @selector(fetchSeriesFailed:);
    
    if(mirrorRequest)
        [request addDependency:mirrorRequest];

    [self addOperation:request];
    [request release];
}

- (void)fetchSeriesCompleted:(id)request;
{
    ASIHTTPRequest* theRequest = request;
    int status = [theRequest responseStatusCode];
    if(status >= 400) {
        [self fetchSeriesFailed:request];
        return;
    }
    //MZLoggerDebug(@"Got response from cache %@", [theRequest didUseCachedResponse] ? @"YES" : @"NO");
    NSXMLDocument* doc = [[[NSXMLDocument alloc] initWithData:[theRequest responseData] options:0 error:NULL] autorelease];

    NSArray* items = [doc nodesForXPath:@"/Data/Series" error:NULL];
    //MZLoggerDebug(@"Got TheTVDB series %d", [items count]);
    for(NSXMLElement* item in items)
    {
        NSString* seriesStr = [item stringForXPath:@"seriesid" error:NULL];
        NSUInteger series = [seriesStr integerValue];

        [self fetchFullSeries:series];
    }
}

- (void)fetchSeriesFailed:(id)request;
{
    ASIHTTPRequest* theRequest = request;
    MZLoggerDebug(@"Request failed with status code %d", [theRequest responseStatusCode]);
    MZLoggerDebug(@"Request failed with data %@", [theRequest responseString]);
    
}

- (void)fetchSeriesBannersCompleted:(id)request;
{
    ASIHTTPRequest* theRequest = request;
    int status = [theRequest responseStatusCode];
    if(status >= 400) {
        [self fetchSeriesBannersFailed:request];
        return;
    }
    //MZLoggerDebug(@"Got response from cache %@", [theRequest didUseCachedResponse] ? @"YES" : @"NO");
    
    NSXMLDocument* doc = [[[NSXMLDocument alloc] initWithData:[theRequest responseData] options:0 error:NULL] autorelease];

    NSMutableArray* banners = [NSMutableArray array];
    NSArray* items = [doc nodesForXPath:@"/Banners/Banner" error:NULL];
    for(NSXMLElement* item in items)
    {
        NSString* language = [item stringForXPath:@"Language" error:NULL];
        if(![language isEqualToString:@"en"])
            continue;

        NSString* type = [item stringForXPath:@"BannerType" error:NULL];
        if(![type isEqualToString:@"season"])
            continue;
            
        NSString* type2 = [item stringForXPath:@"BannerType2" error:NULL];
        if(![type2 isEqualToString:@"season"])
            continue;

        int theSeason = [[item stringForXPath:@"Season" error:NULL] intValue];
        if(theSeason != season)
            continue;

        float rating = [[item stringForXPath:@"Rating" error:NULL] floatValue];

        NSString* path = [item stringForXPath:@"BannerPath" error:NULL];
        NSString* bannerUrl = [NSString stringWithFormat:@"%@/banners/%@",
            bannerMirror,
            path];
        
        RemoteData* data = [[[RemoteData alloc] initWithImageUrl: [NSURL URLWithString:bannerUrl]] autorelease];
        //MZRemoteData* data = [MZRemoteData imageDataWithURL:[NSURL URLWithString:bannerUrl]];
        data.userInfo = [NSString stringWithFormat:@"%f", rating];
        [banners addObject:data];
        [data loadData];
    }
    // The banners file appears to be sorted on rating in descending order but this is
    // not documented anywhere so we sort it just to be sure.
    NSSortDescriptor* desc = [[[NSSortDescriptor alloc] initWithKey:@"userInfo" ascending:NO] autorelease];
    [banners sortUsingDescriptors:[NSArray arrayWithObject:desc]];
    
    NSMutableDictionary* userInfo = (NSMutableDictionary*)theRequest.userInfo;
    [userInfo setObject:[NSArray arrayWithArray:banners] forKey:@"banners"];
}

- (void)fetchSeriesBannersFailed:(id)request;
{
    //ASIHTTPRequest* theRequest = request;
    //MZLoggerDebug(@"Request failed with status code %d", [theRequest responseStatusCode]);
}

- (void)fetchFullSeries:(NSUInteger)theSeries;
{
    NSString* urlStr = [NSString stringWithFormat:@"%@/api/%@/series/%ld/all/en.xml",
            xmlMirror,
            THETVDB_API_KEY,
            (unsigned long)theSeries];
    //MZLoggerDebug(@"Sending request to %@", urlStr);
    MZHTTPRequest* request = [[MZHTTPRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
    [request setDelegate:self];
    request.didFinishBackgroundSelector = @selector(fetchFullSeriesCompleted:);
    request.didFailSelector = @selector(fetchFullSeriesFailed:);

    NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:[NSNumber numberWithUnsignedInteger:theSeries] forKey:@"series"];
    request.userInfo = userInfo;
    
    NSString* bannerUrl = [NSString stringWithFormat:@"%@/api/%@/series/%ld/banners.xml",
            bannerMirror,
            THETVDB_API_KEY,
            (unsigned long)theSeries];
    //MZLoggerDebug(@"Sending request to %@", bannerUrl);
    MZHTTPRequest* bannerRequest = [[MZHTTPRequest alloc] initWithURL:[NSURL URLWithString:bannerUrl]];
    [bannerRequest setDelegate:self];
    bannerRequest.didFinishBackgroundSelector = @selector(fetchSeriesBannersCompleted:);
    bannerRequest.didFailSelector = @selector(fetchSeriesBannersFailed:);
    bannerRequest.userInfo = userInfo;
    [request addDependency:bannerRequest];
    [self queueOperation:bannerRequest];
    [bannerRequest release];
    
    [self queueOperation:request];
    [request release];
}

- (void)fetchFullSeriesCompleted:(id)request;
{
    ASIHTTPRequest* theRequest = request;
    int status = [theRequest responseStatusCode];
    if(status >= 400) {
        [self fetchFullSeriesFailed:request];
        return;
    }

    NSDictionary* userInfo = [theRequest userInfo];
    NSUInteger series = [[userInfo objectForKey:@"series"] unsignedIntegerValue];
    NSArray* banners = [userInfo objectForKey:@"banners"];

    //MZLoggerDebug(@"Got response from cache %@", [theRequest didUseCachedResponse] ? @"YES" : @"NO");
 

    //MZLoggerDebug(@"Got response:\n%@", [theWrapper responseAsText]);
    NSXMLDocument* doc = [[[NSXMLDocument alloc] initWithData:[theRequest responseData] options:0 error:NULL] autorelease];

    NSMutableDictionary* seriesDict = [NSMutableDictionary dictionary];

    NSError* err = nil;
    NSString* tvShow = [doc stringForXPath:@"/Data/Series/SeriesName" error:&err];
    if(tvShow && [tvShow length] > 0)
    {
        MZTag* tvShowTag = [MZTag tagForIdentifier:MZTVShowTagIdent];
        [seriesDict setObject:[tvShowTag objectFromString:tvShow] forKey:MZTVShowTagIdent];
        MZTag* artistTag = [MZTag tagForIdentifier:MZArtistTagIdent];
        [seriesDict setObject:[artistTag objectFromString:tvShow] forKey:MZArtistTagIdent];
    }
    else {
        MZLoggerDebug(@"Series %lu has no name: %@", (unsigned long)series, [err localizedDescription]);
    }


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
    //MZLoggerDebug(@"Got TheTVDB series %d", [items count]);
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

        [episodeDict setObject:[NSNumber numberWithUnsignedInteger:series] forKey:TVDBSeriesIdTagIdent];
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
        
        if(banners)
            [episodeDict setObject:banners forKey:MZPictureTagIdent];
        
        MZSearchResult* result = [MZSearchResult resultWithOwner:provider dictionary:episodeDict];
        [results addObject:result];
    }
    
    //MZLoggerDebug(@"Parsed TheTVDB results %d", [results count]);
    [self performSelectorOnMainThread:@selector(providedResults:) withObject:results waitUntilDone:NO];
}

- (void)providedResults:(NSArray *)results
{
    [delegate searchProvider:provider result:results];
}

- (void)fetchFullSeriesFailed:(id)request;
{
    //ASIHTTPRequest* theRequest = request;
    //MZLoggerDebug(@"Request failed with status code %d", [theRequest responseStatusCode]);
}

@end

