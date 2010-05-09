//
//  TheTVDBPlugin.m
//  MetaZ
//
//  Created by Nigel Graham on 09/04/10.
//  Copyright 2010 Maven-Group. All rights reserved.
//

#import "TheTVDBPlugin.h"
#import "TheTVDBSearchProvider.h"


@implementation TheTVDBPlugin

- (id)init
{
    self = [super init];
    if(self)
    {
        TheTVDBSearchProvider* a = [[[TheTVDBSearchProvider alloc] init] autorelease];
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
    [MZTag registerTag:[MZStringTag tagWithIdentifier:EpisodeQueryTagIdent]];
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
