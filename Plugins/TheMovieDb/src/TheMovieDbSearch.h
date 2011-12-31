//
//  TheMovieDbSearch.h
//  MetaZ
//
//  Created by Brian Olsen on 30/12/11.
//  Copyright 2011 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/MetaZKit.h>


@interface TheMovieDbSearch : MZOperationsController
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

- (void)fetchMovieSearch:(NSString *)name;
- (void)fetchMovieSearchCompleted:(id)request;
- (void)fetchMovieSearchFailed:(id)request;

- (void)fetchMovieInfo:(NSString *)identifier;
- (void)fetchMovieInfoCompleted:(id)request;
- (void)fetchMovieInfoFailed:(id)request;

@end
