//
//  TheMovieDbSearch.m
//  MetaZ
//
//  Created by Brian Olsen on 30/12/11.
//  Copyright 2011 Maven-Group. All rights reserved.
//

#import "TheMovieDbSearch.h"
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

- (void)fetchMovieSearch:(NSString *)name
{
    NSString* url = [[NSString stringWithFormat:
        @"http://api.themoviedb.org/2.1/Movie.search/%@/xml/%@/%@",
        @"en",
        THEMOVIEDB_API_KEY,
        name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    //MZLoggerDebug(@"Sending request to %@", url);
    //MZLoggerDebug(@"Sending request to %@", [NSURL URLWithString:url]);
    MZHTTPRequest* request = [[MZHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setDelegate:self];
    request.didFinishBackgroundSelector = @selector(fetchMovieSearchCompleted:);
    request.didFailSelector = @selector(fetchMovieSearchFailed:);

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
    NSXMLDocument* doc = [[[NSXMLDocument alloc] initWithData:[theRequest responseData] options:0 error:NULL] autorelease];

    NSArray* items = [doc nodesForXPath:@"/OpenSearchDescription/movies/movie" error:NULL];
    //MZLoggerDebug(@"Got TheMovieDb results %d", [items count]);
    for(NSXMLElement* item in items)
    {
        NSString* movieId = [item stringForXPath:@"id" error:NULL];
        [self fetchMovieInfo:movieId];
    }
}

- (void)fetchMovieSearchFailed:(id)request;
{
    //ASIHTTPRequest* theRequest = request;
    //MZLoggerDebug(@"Request failed with status code %d", [theRequest responseStatusCode]);
}



- (void)fetchMovieInfo:(NSString *)identifier;
{
    NSString* url = [[NSString stringWithFormat:
        @"http://api.themoviedb.org/2.1/Movie.getInfo/%@/xml/%@/%@",
        @"en",
        THEMOVIEDB_API_KEY,
        identifier] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    //MZLoggerDebug(@"Sending request to %@", url);
    MZHTTPRequest* request = [[MZHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]];
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
    NSXMLDocument* doc = [[[NSXMLDocument alloc] initWithData:[theRequest responseData] options:0 error:NULL] autorelease];

    NSXMLElement* item = [[doc nodesForXPath:@"/OpenSearchDescription/movies/movie" error:NULL] objectAtIndex:0];

    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    
    NSString* title = [item stringForXPath:@"name" error:NULL];
    if(title && [title length] > 0)
    {
        MZTag* tag = [MZTag tagForIdentifier:MZTitleTagIdent];
        [dict setObject:[tag objectFromString:title] forKey:MZTitleTagIdent];
    }

    NSString* ident = [item stringForXPath:@"id" error:NULL];
    MZTag* identTag = [MZTag tagForIdentifier:TMDbIdTagIdent];
    [dict setObject:[identTag objectFromString:ident] forKey:TMDbIdTagIdent];

    NSString* url = [item stringForXPath:@"url" error:NULL];
    MZTag* urlTag = [MZTag tagForIdentifier:TMDbURLTagIdent];
    [dict setObject:[urlTag objectFromString:url] forKey:TMDbURLTagIdent];

    NSString* imdbId = [item stringForXPath:@"imdb_id" error:NULL];
    if(imdbId && [imdbId length] > 0)
    {
        MZTag* imdbTag = [MZTag tagForIdentifier:MZIMDBTagIdent];
        [dict setObject:[imdbTag objectFromString:imdbId] forKey:MZIMDBTagIdent];
    }
    
    NSString* rating = [item stringForXPath:@"certification" error:NULL];
    MZTag* ratingTag = [MZTag tagForIdentifier:MZRatingTagIdent];
    NSNumber* ratingNr = [ratingTag objectFromString:rating];
    if([ratingNr intValue] != MZNoRating)
        [dict setObject:ratingNr forKey:MZRatingTagIdent];
        
    NSString* description = [item stringForXPath:@"overview" error:NULL];
    if(description && [description length] > 0)
    {
        [dict setObject:description forKey:MZShortDescriptionTagIdent];
        [dict setObject:description forKey:MZLongDescriptionTagIdent];
    }

    NSString* release = [item stringForXPath:@"released" error:NULL];
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
    
    
    NSString* directors = [item stringForXPath:@"cast/person[@job='Director']/@name" error:NULL];
    if(directors)
        [dict setObject:directors forKey:MZDirectorTagIdent];

    NSString* writers = [item stringForXPath:@"cast/person[@job='Screenplay']/@name" error:NULL];
    if(writers)
        [dict setObject:writers forKey:MZScreenwriterTagIdent];
    
    NSString* actors = [item stringForXPath:@"cast/person[@job='Actor']/@name" error:NULL];
    if(actors)
    {
        [dict setObject:actors forKey:MZActorsTagIdent];
        [dict setObject:actors forKey:MZArtistTagIdent];
    }
    
    NSString* genre = [item stringForXPath:@"categories/category[@type='genre'][1]/@name" error:NULL]; 
    if(genre)
        [dict setObject:genre forKey:MZGenreTagIdent];
    
    
    NSMutableArray* images = [NSMutableArray array];
    NSArray* imageNodes = [item nodesForXPath:@"images/image[@size='original' and @type='poster']" error:NULL];
    for(NSXMLElement* image in imageNodes)
    {
        NSString* path = [image stringForXPath:@"@url" error:NULL];
        
        MZRemoteData* data = [MZRemoteData imageDataWithURL:[NSURL URLWithString:path]];
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
