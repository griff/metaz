//
//  AmazonPlugin.m
//  MetaZ
//
//  Created by Brian Olsen on 16/11/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "AmazonPlugin.h"
#import "AmazonSearchProvider.h"

@implementation AmazonPlugin

- (id)init
{
    self = [super init];
    if(self)
    {
        AmazonSearchProvider* a = [[[AmazonSearchProvider alloc] init] autorelease];
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
