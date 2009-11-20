//
//  MZRESTSearch.h
//  MetaZ
//
//  Created by Brian Olsen on 18/11/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/MZRESTWrapper.h>
#import <MetaZKit/MZSearchProvider.h>

@interface MZRESTSearch : NSOperation <MZRESTWrapperDelegate>
{
    id provider;
    MZRESTWrapper* wrapper;
    id<MZSearchProviderDelegate> delegate;
    NSURL* searchURL;
    NSString* verb;
    NSDictionary* parameters;
    BOOL isFinished;
    BOOL isExecuting;
}
+ (Class)restWrapper;

@property(assign) BOOL isFinished;
@property(assign) BOOL isExecuting;

- (id)initWithProvider:(id)provider delegate:(id<MZSearchProviderDelegate>)delegate url:(NSURL *)url usingVerb:(NSString *)verb parameters:(NSDictionary *)params;
- (void)start;
- (BOOL)isConcurrent;
- (BOOL)isExecuting;
- (BOOL)isFinished;
- (void)cancel;

@end
