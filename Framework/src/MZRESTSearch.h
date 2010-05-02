//
//  MZRESTSearch.h
//  MetaZ
//
//  Created by Brian Olsen on 18/11/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/MZSearchProvider.h>
#import <MetaZKit/MZRESTOperation.h>

@interface MZRESTSearchResult : MZRESTOperation
{
    id provider;
    id<MZSearchProviderDelegate> delegate;
}

- (id)initWithProvider:(id)provider delegate:(id<MZSearchProviderDelegate>)delegate url:(NSURL *)url usingVerb:(NSString *)verb parameters:(NSDictionary *)params;

- (NSArray *)parseResult;

@end

@interface MZRESTSearch : MZRESTSearchResult
{
}

- (void)operationFinished;

@end

