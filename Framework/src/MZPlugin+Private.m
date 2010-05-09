//
//  MZPlugin-Private.m
//  MetaZ
//
//  Created by Brian Olsen on 27/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "MZPlugin+Private.h"


@implementation MZPlugin (Private)

- (BOOL)isEnabled
{
    NSArray* disabled = [[NSUserDefaults standardUserDefaults] arrayForKey:DISABLED_KEY];
    return ![disabled containsObject:[[self bundle] bundleIdentifier]];
}

- (void)setEnabled:(BOOL)enabled
{
    NSArray* disabledA = [[NSUserDefaults standardUserDefaults] arrayForKey:DISABLED_KEY];
    NSMutableSet* disabled;
    if(disabledA)
        disabled = [NSMutableSet setWithArray:disabledA];
    else
        disabled = [NSMutableSet set];
    if(enabled)
        [disabled removeObject:[[self bundle] bundleIdentifier]];
    else
        [disabled addObject:[[self bundle] bundleIdentifier]];
    [[NSUserDefaults standardUserDefaults] setObject:[disabled allObjects] forKey:DISABLED_KEY];
}

- (BOOL)isBuiltIn
{
    return NO;
}

- (BOOL)canUnload
{
    if([self retainCount]>1)
        return NO;
    for(id obj in [self dataProviders])
        if([obj retainCount]>1)
            return NO;
    for(id obj in [self searchProviders])
        if([obj retainCount]>1)
            return NO;
    return YES;
}
@end
