//
//  TheMovieDbPlugin.m
//  MetaZ
//
//  Created by Brian Olsen on 29/12/11.
//  Copyright 2011 Maven-Group. All rights reserved.
//

#import "TheMovieDbPlugin.h"
#import "TheMovieDbSearchProvider.h"

@implementation TheMovieDbPlugin

- (id)init
{
    self = [super init];
    if(self)
    {
        TheMovieDbSearchProvider* a = [[[TheMovieDbSearchProvider alloc] init] autorelease];
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
    [MZTag registerTag:[MZStringTag tagWithIdentifier:TMDbIdTagIdent]];
    [MZTag registerTag:[MZStringTag tagWithIdentifier:TMDbURLTagIdent]];
    [super didLoad];
}

- (BOOL)isBuiltIn
{
    return YES;
}

- (NSArray *)searchProviders
{
    return searchProviders;
}

@end
