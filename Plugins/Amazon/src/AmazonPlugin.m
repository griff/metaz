//
//  AmazonPlugin.m
//  MetaZ
//
//  Created by Brian Olsen on 16/11/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "AmazonPlugin.h"


@implementation AmazonPlugin

+ (void)initialize
{
    static BOOL initialized = NO;
    /* Make sure code only gets executed once. */
    if (initialized == YES) return;
    initialized = YES;

    [MZTag registerTag:[MZStringTag tagWithIdentifier:ASINTagIdent]];
}

- (id)init
{
    self = [super init];
    if(self)
    {
        /*
        TCSearchProvider* a = [[[TCSearchProvider alloc] init] autorelease];
        searchProviders  = [[NSArray arrayWithObject:a] retain];
        */
        searchProviders = [[NSArray array] retain];
    }
    return self;
}

- (void)dealloc
{
    [searchProviders release];
    [super dealloc];
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
