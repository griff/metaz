//
//  TheMovieDbSearch.m
//  MetaZ
//
//  Created by Brian Olsen on 30/12/11.
//  Copyright 2011 Maven-Group. All rights reserved.
//

#import "TheMovieDbSearch.h"
#import <MetaZKit/JSONKit.h>
#import <MetaZKit/MZLogger.h>
#import "Access.h"
#import "TheMovieDbPlugin.h"

@implementation TheMovieDbSearch

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
    [configurationRequest release];
    [imageBaseURL release];
    [super dealloc];
}

@synthesize provider;
@synthesize delegate;

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

- (void)fetchConfiguration;
{
    NSString* url = [NSString stringWithFormat:
                     @"http://api.themoviedb.org/3/configuration?api_key=%@",
                     THEMOVIEDB_API_KEY];
    configurationRequest = [[MZHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [configurationRequest addRequestHeader:@"Accept" value:@"application/json"];
    [configurationRequest setDelegate:self];
    configurationRequest.cacheStoragePolicy = ASICacheForSessionDurationCacheStoragePolicy;
    configurationRequest.didFinishBackgroundSelector = @selector(fetchConfigurationCompleted:);
    configurationRequest.didFailSelector = @selector(fetchConfigurationFailed:);
    
    [self addOperation:configurationRequest];
}

- (void)fetchConfigurationCompleted:(id)request;
{
    ASIHTTPRequest* theRequest = request;
    int status = [theRequest responseStatusCode];
    if(status >= 400) {
        [self fetchConfigurationFailed:request];
        return;
    }
 
    id obj = [[theRequest responseData] objectFromJSONData];
    imageBaseURL = [[[obj objectForKey:@"images"] objectForKey:@"base_url"] retain];
}

- (void)fetchConfigurationFailed:(id)request;
{
    imageBaseURL = @"http://d3gtl9l2a4fn1j.cloudfront.net/t/p/";
}

- (void)fetchMovieSearch:(NSString *)query
{
    NSString* url = [NSString stringWithFormat:
        @"http://api.themoviedb.org/3/search/movie?api_key=%@&language=%@&query=%@",
        THEMOVIEDB_API_KEY,
        @"en",
        [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

    //MZLoggerDebug(@"Sending request to %@", url);
    //MZLoggerDebug(@"Sending request to %@", [NSURL URLWithString:url]);
    MZHTTPRequest* request = [[MZHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request setDelegate:self];
    request.didFinishBackgroundSelector = @selector(fetchMovieSearchCompleted:);
    request.didFailSelector = @selector(fetchMovieSearchFailed:);

    if(configurationRequest)
        [request addDependency:configurationRequest];
    
    [self addOperation:request];
    [request release];
}

- (void)fetchMovieSearchCompleted:(id)request;
{
    ASIHTTPRequest* theRequest = request;
    int status = [theRequest responseStatusCode];
    if(status >= 400) {
        [self fetchMovieSearchFailed:request];
        return;
    }
    //MZLoggerDebug(@"Got response from cache %@", [theRequest didUseCachedResponse] ? @"YES" : @"NO");
    id doc = [[theRequest responseData] objectFromJSONData];

    NSArray* items = [doc objectForKey:@"results"];
    //MZLoggerDebug(@"Got TheMovieDb results %d", [items count]);
    for(id item in items)
    {
        NSNumber* movieId = [item objectForKey:@"id"];
        [self fetchMovieInfo:movieId];
    }
}

- (void)fetchMovieSearchFailed:(id)request;
{
    //ASIHTTPRequest* theRequest = request;
    //MZLoggerDebug(@"Request failed with status code %d", [theRequest responseStatusCode]);
}



- (void)fetchMovieInfo:(NSNumber *)identifier;
{
    NSString* url = [NSString stringWithFormat:
        @"http://api.themoviedb.org/3/movie/%@?api_key=%@&language=%@&append_to_response=credits,images,releases",
        identifier,
        THEMOVIEDB_API_KEY,
        @"en"];

    //MZLoggerDebug(@"Sending request to %@", url);
    MZHTTPRequest* request = [[MZHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request setDelegate:self];
    request.didFinishBackgroundSelector = @selector(fetchMovieInfoCompleted:);
    request.didFailSelector = @selector(fetchMovieInfoFailed:);

    [self queueOperation:request];
    [request release];
}

- (void)fetchMovieInfoCompleted:(id)request;
{
    ASIHTTPRequest* theRequest = request;
    int status = [theRequest responseStatusCode];
    if(status >= 400) {
        [self fetchMovieInfoFailed:request];
        return;
    }

    //MZLoggerDebug(@"Got response from cache %@", [theRequest didUseCachedResponse] ? @"YES" : @"NO");
    id doc = [[theRequest responseData] objectFromJSONData];

    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    
    NSString* title = [doc objectForKey:@"title"];
    if(title && [title length] > 0)
    {
        MZTag* tag = [MZTag tagForIdentifier:MZTitleTagIdent];
        [dict setObject:[tag objectFromString:title] forKey:MZTitleTagIdent];
    }

    NSNumber* ident = [doc objectForKey:@"id"];
    MZTag* identTag = [MZTag tagForIdentifier:TMDbIdTagIdent];
    [dict setObject:[identTag objectFromString:[ident stringValue]] forKey:TMDbIdTagIdent];

    NSString* url = [NSString stringWithFormat:@"http://www.themoviedb.org/movie/%@", ident];
    //NSString* url = [doc objectForKey:@"homepage"];
    MZTag* urlTag = [MZTag tagForIdentifier:TMDbURLTagIdent];
    [dict setObject:[urlTag objectFromString:url] forKey:TMDbURLTagIdent];

    NSString* imdbId = [doc objectForKey:@"imdb_id"];
    if(imdbId && [imdbId length] > 0)
    {
        MZTag* imdbTag = [MZTag tagForIdentifier:MZIMDBTagIdent];
        [dict setObject:[imdbTag objectFromString:imdbId] forKey:MZIMDBTagIdent];
    }

    NSString* description = [doc objectForKey:@"overview"];
    if(description && [description length] > 0)
    {
        [dict setObject:description forKey:MZShortDescriptionTagIdent];
        [dict setObject:description forKey:MZLongDescriptionTagIdent];
    }

    NSArray* countries = [[doc objectForKey:@"releases"] objectForKey:@"countries"];
    if(countries && [countries count] > 0) {
        NSString* rating = [[countries objectAtIndex:0] objectForKey:@"certification"];
        MZTag* ratingTag = [MZTag tagForIdentifier:MZRatingTagIdent];
        NSNumber* ratingNr = [ratingTag objectFromString:rating];
        if([ratingNr intValue] != MZNoRating)
            [dict setObject:ratingNr forKey:MZRatingTagIdent];
    }

    NSString* release = [doc objectForKey:@"release_date"];
    if( release && [release length] > 0 )
    {
        NSDateFormatter* format = [[[NSDateFormatter alloc] init] autorelease];
        format.dateFormat = @"yyyy-MM-dd";
        NSDate* date = [format dateFromString:release];
        if(date) 
            [dict setObject:date forKey:MZDateTagIdent];
        else
            MZLoggerError(@"Unable to parse release date '%@'", release);
    }
    
    
    NSMutableArray* directorsArray = [NSMutableArray array];
    NSMutableArray* writersArray = [NSMutableArray array];
    NSMutableArray* producersArray = [NSMutableArray array];
    NSDictionary* credits = [doc objectForKey:@"credits"];
    
    for(NSDictionary* crew in [credits objectForKey:@"crew"])
    {
        NSString* department = [crew objectForKey:@"department"];
        NSString* job = [crew objectForKey:@"job"];
        NSString* name = [crew objectForKey:@"name"];
        if([department isEqualToString:@"Writing"]) {
            [writersArray addObject:name];
        } else if([department isEqualToString:@"Directing"]) {
            [directorsArray addObject:name];
        } else if([job rangeOfString:@"Producer"].location != NSNotFound)
            [producersArray addObject:name];
    }
    
    if([directorsArray count] > 0) {
        NSString* directors = [directorsArray componentsJoinedByString:@", "];
        [dict setObject:directors forKey:MZDirectorTagIdent];
    }
    
    if([writersArray count] > 0) {
        NSString* writers = [writersArray componentsJoinedByString:@", "];
        [dict setObject:writers forKey:MZScreenwriterTagIdent];
    }
    
    if([producersArray count] > 0) {
        NSString* producers = [producersArray componentsJoinedByString:@", "];
        [dict setObject:producers forKey:MZProducerTagIdent];
    }

    NSMutableArray* actorsArray = [NSMutableArray array];
    for(NSDictionary* member in [credits objectForKey:@"cast"])
    {
        [actorsArray addObject:[member objectForKey:@"name"]];
    }
    if([actorsArray count] > 0) {
        NSString* actors = [actorsArray componentsJoinedByString:@", "];
        [dict setObject:actors forKey:MZActorsTagIdent];
        [dict setObject:actors forKey:MZArtistTagIdent];
    }

    
    NSArray* genres = [doc objectForKey:@"genres"];
    if([genres count] > 0) {
        NSString* genre = [[genres objectAtIndex:0] objectForKey:@"name"];
        [dict setObject:genre forKey:MZGenreTagIdent];
    }
    
    NSMutableArray* images = [NSMutableArray array];
    NSArray* posters = [[doc objectForKey:@"images"] objectForKey:@"posters"];
    for(NSDictionary* poster in posters)
    {
        NSString* path = [poster objectForKey:@"file_path"];
        NSString* url = [NSString stringWithFormat:@"%@%@%@", imageBaseURL, @"original", path];
        MZRemoteData* data = [MZRemoteData imageDataWithURL:[NSURL URLWithString:url]];
        [images addObject:data];
        [data loadData];
    }
    if([images count] > 0)
        [dict setObject:[NSArray arrayWithArray:images] forKey:MZPictureTagIdent];

    MZSearchResult* result = [MZSearchResult resultWithOwner:provider dictionary:dict];
    [self performSelectorOnMainThread:@selector(providedResult:) withObject:result waitUntilDone:NO];
}

- (void)providedResult:(MZSearchResult *)result
{
    [delegate searchProvider:provider result:[NSArray arrayWithObject:result]];
}

- (void)fetchMovieInfoFailed:(id)request;
{
    //ASIHTTPRequest* theRequest = request;
    //MZLoggerDebug(@"Request failed with status code %d", [theRequest responseStatusCode]);
}

@end
