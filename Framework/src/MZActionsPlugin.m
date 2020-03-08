//
//  MZActionsPlugin.m
//  MetaZ
//
//  Created by Brian Olsen on 05/11/12.
//  Copyright 2012 Maven-Group. All rights reserved.
//

#import "MZActionsPlugin.h"

#define ENABLED_ACTIONS_KEY @"enabledActionPlugins"

@implementation MZActionsPlugin

- (void)dealloc
{
    [self unregisterObservers];
    [super dealloc];
}

- (void)didLoad
{
    if([self isEnabled])
        [self registerObservers];
}

- (void)willUnload
{
    [self unregisterObservers];
}

- (BOOL)isEnabled
{
    NSArray* enabled = [[NSUserDefaults standardUserDefaults] arrayForKey:ENABLED_ACTIONS_KEY];
    return [enabled containsObject:self.identifier] && [super isEnabled];
}

- (void)setEnabled:(BOOL)enabledValue
{
    NSArray* enabledA = [[NSUserDefaults standardUserDefaults] arrayForKey:ENABLED_ACTIONS_KEY];
    NSMutableSet* enabled;
    if(enabledA)
        enabled = [NSMutableSet setWithArray:enabledA];
    else
        enabled = [NSMutableSet set];

    BOOL old = [enabled containsObject:self.identifier];

    if(enabledValue)
        [enabled addObject:self.identifier];
    else
        [enabled removeObject:self.identifier];
    [[NSUserDefaults standardUserDefaults] setObject:[enabled allObjects] forKey:ENABLED_ACTIONS_KEY];
    
    if(!old && enabledValue)
        [self registerObservers];
    else if (old && !enabledValue)
        [self unregisterObservers];
}

- (void)registerObservers {}

- (void)unregisterObservers
{
    [[NSNotificationCenter defaultCenter]
        removeObserver:self];
}

@end
