//
//  TCSearch.h
//  MetaZ
//
//  Created by Brian Olsen on 13/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/MetaZKit.h>

@interface TCSearch : NSOperation <MZRESTWrapperDelegate>
{
    id provider;
    MZRESTWrapper* wrapper;
    NSDictionary* mapping;
    //NSArray* ratingNames;
    id<MZSearchProviderDelegate> delegate;
    NSURL* searchURL;
    NSDictionary* parameters;
    BOOL isFinished;
    BOOL isExecuting;
}
@property(assign) BOOL isFinished;
@property(assign) BOOL isExecuting;

- (id)initWithProvider:(id)provider delegate:(id<MZSearchProviderDelegate>)delegate url:(NSURL *)url parameters:(NSDictionary *)params;
- (void)start;
- (BOOL)isConcurrent;
- (BOOL)isExecuting;
- (BOOL)isFinished;
- (void)cancel;

@end
