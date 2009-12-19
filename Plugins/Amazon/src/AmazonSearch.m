//
//  AmazonSearch.m
//  MetaZ
//
//  Created by Brian Olsen on 20/11/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "AmazonSearch.h"
#import "Access.h"
#import "AmazonRequest.h"

@implementation AmazonSearch

+ (Class)restWrapper
{
    return [AmazonRequest class];
}

- (id)initWithProvider:(id)theProvider delegate:(id<MZSearchProviderDelegate>)theDelegate url:(NSURL *)url parameters:(NSDictionary *)params;
{
    self = [super initWithProvider:theProvider delegate:theDelegate url:url usingVerb:@"GET" parameters:params];
    if(self)
    {
        NSArray* tags = [NSArray arrayWithObjects:
            MZTitleTagIdent, 
            MZDirectorTagIdent, MZProducerTagIdent,
            MZScreenwriterTagIdent, MZActorsTagIdent,
            MZShortDescriptionTagIdent,
            ASINTagIdent,
            
            MZLongDescriptionTagIdent,
            MZAdvisoryTagIdent, MZCopyrightTagIdent,
            MZCommentTagIdent, MZArtistTagIdent,
            MZTVShowTagIdent, MZTVSeasonTagIdent,
            MZTVEpisodeTagIdent, MZTVNetworkTagIdent,
            MZSortTitleTagIdent, MZSortAlbumArtistTagIdent,
            MZSortAlbumTagIdent, MZSortTVShowTagIdent,
            MZGenreTagIdent,
            nil];
        NSArray* keys = [NSArray arrayWithObjects:
            @"ItemAttributes/Title",
            @"ItemAttributes/Director", @"ItemAttributes/Creator[@Role='Producer']",
            @"ItemAttributes/Creator[@Role='Writer']", @"ItemAttributes/Actor",
            @"ItemAttributes/Feature",
            @"ASIN",
            
            @"movieTags/info/longDescription",
            @"movieTags/info/advisory", @"movieTags/info/copyright",
            @"movieTags/info/comments", @"movieTags/info/artist/artistName",
            @"movieTags/television/showName", @"movieTags/television/season",
            @"movieTags/television/episode", @"movieTags/television/network",
            @"movieTags/sorting/name", @"movieTags/sorting/albumArtist",
            @"movieTags/sorting/album", @"movieTags/sorting/show",
            @"movieTags/info/genre", 
            nil];
        mapping = [[NSDictionary alloc] initWithObjects:tags forKeys:keys];
        AmazonRequest* req = (AmazonRequest*)wrapper;
        [req setAccessKeyId:AMAZON_ACCESS_ID];
        [req setSecretAccessKey:AMAZON_ACCESS_KEY];
    }
    return self;
}

- (void)dealloc
{
    [mapping release];
    [super dealloc];
}

#pragma mark - MZRESTWrapperDelegate

- (void)wrapper:(MZRESTWrapper *)theWrapper didRetrieveData:(NSData *)data
{
    //MZLoggerDebug(@"Got amazon response:\n%@", [theWrapper responseAsText]);
    NSXMLDocument* doc = [theWrapper responseAsXml];

    NSString* errorMessage = [doc stringForXPath:@"/ItemSearchResponse/Items/Request/Errors/Error/Code" error:NULL];
    if(![errorMessage isEqual:@""])
        MZLoggerError(@"Amazon error: %@", errorMessage);
        
    //NSString* totalResults = [doc stringForXPath:@"/ItemSearchResponse/Items/TotalResults" error:NULL];
    //NSString* totalPages = [doc stringForXPath:@"/ItemSearchResponse/Items/TotalPages" error:NULL];

    NSArray* items = [doc nodesForXPath:@"/ItemSearchResponse/Items/Item" error:NULL];
    NSMutableArray* results = [NSMutableArray array];
    MZLoggerDebug(@"Got Amazon results %d", [items count]);
    for(NSXMLElement* item in items)
    {
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        for(NSString* xpath in [mapping allKeys])
        {
            NSString* tagId = [mapping objectForKey:xpath];
            MZTag* tag = [MZTag tagForIdentifier:tagId];
            NSString* value = [item stringForXPath:xpath error:NULL];
            if([value length] > 0)
            {
                id obj = [tag objectFromString:value];
                if(obj)
                    [dict setObject:obj forKey:tagId];
            }
        }

        //NSString* asin = [dict objectForKey:ASINTagIdent];

        NSArray* reviews = [item nodesForXPath:@"EditorialReviews/EditorialReview/Content" error:NULL];
        if([reviews count] > 0)
        {
            NSString* review = [[reviews objectAtIndex:0] stringValue];
            [dict setObject:review forKey:MZLongDescriptionTagIdent];
        }

        MZTag* ratingTag = [MZTag tagForIdentifier:MZRatingTagIdent];
        NSString* rating = [item stringForXPath:@"ItemAttributes/AudienceRating" error:NULL];
        NSNumber* ratingNr = [ratingTag objectFromString:rating];
        if([ratingNr intValue] != MZNoRating)
            [dict setObject:ratingNr forKey:MZRatingTagIdent];
        /*
        NSInteger ratingNr = [ratingNames indexOfObject:rating];
        if(ratingNr != NSNotFound)
        {
            [dict setObject:[NSNumber numberWithInt:ratingNr] forKey:MZRatingTagIdent];
        }
        */


        NSString* coverArtLarge = [item stringForXPath:@"LargeImage/URL" error:NULL];
        if([coverArtLarge length] > 0)
        {
            /*
            MZLoggerDebug(@"ASIN %@", asin);
            MZLoggerDebug(@"Image large url: %@", coverArtLarge);
            */
            NSURL* url = [NSURL URLWithString:coverArtLarge];
            MZRemoteData* data = [MZRemoteData dataWithURL:url];
            [dict setObject:data forKey:MZPictureTagIdent];
            if([NSThread mainThread] != [NSThread currentThread])
                [data performSelectorOnMainThread:@selector(loadData) withObject:nil waitUntilDone:NO];
            else
                [data loadData];
        }

        MZSearchResult* result = [MZSearchResult resultWithOwner:provider dictionary:dict];
        [results addObject:result];
    }

    MZLoggerDebug(@"Parsed Amazon results %d", [results count]);
    [delegate searchProvider:provider result:results];
    
    // TODO Make more requests for other pages
    [delegate searchFinished];
    self.isExecuting = NO;
    self.isFinished = YES;
}

@end
