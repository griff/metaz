//
//  TagChimpPlugin.m
//  MetaZ
//
//  Created by Brian Olsen on 11/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "TagChimpPlugin.h"
#import "TCSearchProvider.h"

@implementation TagChimpPlugin

- (id)init
{
    self = [super init];
    if(self)
    {
        TCSearchProvider* a = [[[TCSearchProvider alloc] init] autorelease];
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
    [MZTag registerTag:[MZIntegerTag tagWithIdentifier:TagChimpIdTagIdent]];
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
