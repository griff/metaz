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

+ (void)initialize
{
    @synchronized(self)
    {
        static BOOL initialized = NO;
        if (initialized == YES) return;
        initialized = YES;
    }

    [MZTag registerTag:[MZIntegerTag tagWithIdentifier:TagChimpIdTagIdent]];
}

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

- (BOOL)isBuiltIn
{
    return YES;
}

- (NSArray *)searchProviders
{
    return searchProviders;
}

@end
