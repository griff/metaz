//
//  TheTVDBSearch.h
//  MetaZ
//
//  Created by Nigel Graham on 10/04/10.
//  Copyright 2010 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/MetaZKit.h>

@interface TheTVDBSearch : MZOperationsController
{
    NSOperationQueue* queue;
    id provider;
    id<MZSearchProviderDelegate> delegate;
}
@property(readonly) id provider;
@property(readonly) id<MZSearchProviderDelegate> delegate;

- (id)initWithProvider:(id)provider delegate:(id<MZSearchProviderDelegate>)delegate queue:(NSOperationQueue *)queue;

- (void)queueOperation:(NSOperation *)operation;

- (void)operationsFinished;

@end


@interface TheTVDBUpdateMirrors : MZRESTOperation
{
}
+(NSString *)findMirror;

@end


@interface TheTVDBGetSeries : MZRESTOperation
{
    TheTVDBSearch* search;
    NSUInteger season;
    NSInteger episode;
}
- (id)initWithSearch:(TheTVDBSearch*)search name:(NSString *)name season:(NSUInteger)theSeason episode:(NSInteger)theEpisode;

@end


@interface TheTVDBBaseSeriesLoader : MZRESTOperation
{
    NSUInteger series;
    NSDictionary* data;
}
- (id)initWithSeries:(NSUInteger)theSeries;

@property(readonly) NSUInteger series;
@property(copy) NSDictionary* data;

@end


@interface TheTVDBEpisodeLoader : MZRESTSearchResult
{
    TheTVDBBaseSeriesLoader* series;
    NSUInteger season;
    NSUInteger episode;
}

- (id)initWithProvider:(id)provider delegate:(id<MZSearchProviderDelegate>)delegate series:(TheTVDBBaseSeriesLoader *)theSeries season:(NSUInteger)theSeason episode:(NSUInteger)theEpisode dvdOrder:(BOOL)order;

- (NSDictionary *)parse;

@end


@interface TheTVDBEpisodeFinder : TheTVDBEpisodeLoader
{
    TheTVDBSearch* search;
}

- (id)initWithSearch:(TheTVDBSearch*)search series:(TheTVDBBaseSeriesLoader *)theSeries season:(NSUInteger)theSeason episode:(NSUInteger)theEpisode;

- (NSDictionary *)parse;

@end


@interface TheTVDBSeasonFinder : TheTVDBEpisodeLoader
{
    NSInteger lowestFoundNo;
    NSInteger highestTriedNo;
    TheTVDBSearch* search;
}

- (id)initWithSearch:(TheTVDBSearch*)search series:(TheTVDBBaseSeriesLoader *)theSeries season:(NSUInteger)theSeason;

- (NSDictionary *)parse;

@end
