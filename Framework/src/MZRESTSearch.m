//
//  MZRESTSearch.m
//  MetaZ
//
//  Created by Brian Olsen on 18/11/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "MZRESTSearch.h"
#import <MetaZKit/MZLogger.h>
#import <MetaZKit/MZSearchProvider.h>

@implementation MZRESTSearchResult

- (id)initWithProvider:(id)theProvider delegate:(id<MZSearchProviderDelegate>)theDelegate url:(NSURL *)url usingVerb:(NSString *)theVerb parameters:(NSDictionary *)params;
{
    self = [super initWithURL:url usingVerb:theVerb parameters:params];
    if(self)
    {
        provider = theProvider;
        delegate = [theDelegate retain];
    }
    return self;
}

- (void)dealloc
{
    [delegate release];
    [super dealloc];
}

- (NSArray *)parseResult
{
    return [NSArray array];
}

#pragma mark - MZRESTWrapperDelegate

- (void)wrapper:(MZRESTWrapper *)theWrapper didRetrieveData:(NSData *)data
{
    if(theWrapper.statusCode == 200)
        [delegate searchProvider:provider result:[self parseResult]];
    [super wrapper:theWrapper didRetrieveData:data];
}

@end


@implementation MZRESTSearch

- (void)operationFinished
{
    [delegate searchFinished];
}

@end
