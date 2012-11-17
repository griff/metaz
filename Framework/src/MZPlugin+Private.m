//
//  MZPlugin-Private.m
//  MetaZ
//
//  Created by Brian Olsen on 27/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "MZPlugin+Private.h"


@implementation MZPlugin (Private)

- (BOOL)isBuiltIn
{
    return NO;
}

- (BOOL)canUnload
{/*
    if([self retainCount]>1)
        return NO;
    for(id obj in [self dataProviders])
        if([obj retainCount]>1)
            return NO;
    for(id obj in [self searchProviders])
        if([obj retainCount]>1)
            return NO;*/
    return YES;
}

- (BOOL)unload
{
    return [bundle unload];
}

@end
