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
    MZHTTPRequest* mirrorRequest;
    NSString* bannerMirror;
    NSString* xmlMirror;
    NSUInteger season;
    NSInteger episode;
}
@property(readonly) id provider;
@property(readonly) id<MZSearchProviderDelegate> delegate;
@property(assign) NSUInteger season;
@property(assign) NSInteger episode;

+ (id)searchWithProvider:(id)provider delegate:(id<MZSearchProviderDelegate>)delegate queue:(NSOperationQueue *)queue;
- (id)initWithProvider:(id)provider delegate:(id<MZSearchProviderDelegate>)delegate queue:(NSOperationQueue *)queue;

- (void)queueOperation:(NSOperation *)operation;

- (void)operationsFinished;

- (void)updateMirror;
- (void)updateMirrorCompleted:(id)request;
- (void)updateMirrorFailed:(id)request;

- (void)fetchSeriesByName:(NSString *)name;
- (void)fetchSeriesCompleted:(id)request;
- (void)fetchSeriesFailed:(id)request;

- (void)fetchFullSeries:(NSUInteger)theSeries;
- (void)fetchFullSeriesCompleted:(id)request;
- (void)fetchFullSeriesFailed:(id)request;

- (void)fetchSeriesBannersCompleted:(id)request;
- (void)fetchSeriesBannersFailed:(id)request;

@end

