//
//  AtomicParsleyPlugin.m
//  MetaZ
//
//  Created by Brian Olsen on 27/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "AtomicParsleyPlugin.h"
#import "APDataProvider.h"

@implementation AtomicParsleyPlugin

- (id)init
{
    self = [super init];
    if(self)
    {
        APDataProvider* a = [[APDataProvider alloc] init];
        dataProviders  = [[NSArray arrayWithObject:a] retain];
        [a release];
    }
    return self;
}

- (void)dealloc
{
    [dataProviders release];
    [super dealloc];
}

- (BOOL)isBuiltIn
{
    return YES;
}

- (NSArray *)dataProviders
{
    return dataProviders;
}

@end
