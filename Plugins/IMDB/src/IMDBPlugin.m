//
//  IMDBPlugin.m
//  MetaZ
//
//  Created by Brian Olsen on 20/12/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "IMDBPlugin.h"
#import "IMDBSearchProvider.h"
#import <RubyCocoa/RBRuntime.h>

@implementation IMDBPlugin

- (id)init
{
    self = [super init];
    if(self)
    {
        IMDBSearchProvider* a = [[[IMDBSearchProvider alloc] init] autorelease];
        searchProviders  = [[NSArray arrayWithObject:a] retain];
    }
    return self;
}

- (void)dealloc
{
    [searchProviders release];
    [super dealloc];
}

- (void)didLoad
{
    RBBundleInit("imdb_plugin.rb", [self class], nil);
}

- (NSArray *)searchProviders
{
    return searchProviders;
}

@end
