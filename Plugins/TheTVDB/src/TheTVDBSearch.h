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

+ (id)searchWithProvider:(id)provider delegate:(id<MZSearchProviderDelegate>)delegate queue:(NSOperationQueue *)queue;
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


@interface TheTVDBFullSeriesLoader : MZRESTSearchResult
{
    NSUInteger series;
    NSUInteger season;
    NSInteger episode;
}
- (id)initWithProvider:(id)provider delegate:(id<MZSearchProviderDelegate>)delegate series:(NSUInteger)theSeries season:(NSUInteger)theSeason episode:(NSInteger)theEpisode;

@property(readonly) NSUInteger series;
@property(readonly) NSUInteger season;
@property(readonly) NSInteger episode;

@end
