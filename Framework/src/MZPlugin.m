//
//  MZPlugin.m
//  MetaZ
//
//  Created by Brian Olsen on 26/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <MetaZKit/MZPlugin.h>

#define DISABLED_KEY @"disabledPlugins"

@implementation MZPlugin

- (MZPlugin *)initWithBundle:(NSBundle *)theBundle
{
    self = [super init];
    if(self)
    {
        bundle = [theBundle retain];
    }
    return self;
}

- (MZPlugin *)init
{
    return [self initWithBundle:[NSBundle bundleForClass:[self class]]];
}

- (void)dealloc
{
    [preferencesView release];
    [nib release];
    [topLevelObjects release];
    [bundle release];
    [super dealloc];
}

@synthesize bundle;

- (NSString *)identifier
{
    return [bundle bundleIdentifier];
}

- (NSString *)pluginPath
{
    return [bundle bundlePath];
}

- (BOOL)isEnabled
{
    NSArray* disabled = [[NSUserDefaults standardUserDefaults] arrayForKey:DISABLED_KEY];
    return ![disabled containsObject:self.identifier];
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
        [disabled removeObject:self.identifier];
    else
        [disabled addObject:self.identifier];
    [[NSUserDefaults standardUserDefaults] setObject:[disabled allObjects] forKey:DISABLED_KEY];
}

- (BOOL)canEnable;
{
    return YES;
}

- (void)didLoad {}
- (void)willUnload {}

- (NSString *)label
{
    if(self.bundle)
    {
        NSString* name = [self.bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        if(!name)
            name = [self.bundle objectForInfoDictionaryKey:@"CFBundleName"];
        if(name)
            return name;
    }
    NSString* className = [self className];
    if([className hasPrefix:@"MZ"])
        className = [className substringFromIndex:2];
    if([className hasSuffix:@"Plugin"])
        className = [className substringToIndex:[className length]-6];
    
    NSUInteger length = [className length];
    NSUInteger oldloc = 0;
    NSRange range = [className rangeOfCharacterFromSet:[NSCharacterSet uppercaseLetterCharacterSet]];
    NSMutableString* ret = [NSMutableString stringWithCapacity:10];
    NSString* sub;
    while(range.location != NSNotFound)
    {
        sub = [className substringWithRange:NSMakeRange(oldloc, range.location-oldloc)];
        if(sub.length > 1 && ret.length > 0)
            [ret appendString:@" "];
        [ret appendString:sub];
        NSUInteger max = NSMaxRange(range);
        oldloc = range.location;
        range = [className rangeOfCharacterFromSet:[NSCharacterSet uppercaseLetterCharacterSet]
                                           options:0
                                             range:NSMakeRange(max, length-max)];
    }
    sub = [className substringWithRange:NSMakeRange(oldloc, length-oldloc)];
    if(sub.length > 1 && ret.length > 0)
        [ret appendString:@" "];
    [ret appendString:sub];
    return [NSString stringWithString:ret];
}

- (NSView *)loadPreferencesView
{
    if(![self preferencesView])
    {
        NSString* nibName = [self preferencesNibName];
        nib = [[NSNib alloc] 
            initWithNibNamed:nibName 
                      bundle:self.bundle];
        if(!nib)
            return nil;
        
        NSArray* theTopLevelObjects = nil;
        if([nib instantiateWithOwner:self topLevelObjects:&theTopLevelObjects])
            topLevelObjects = [theTopLevelObjects retain];
    }
    return [self preferencesView];
}

- (NSString *)preferencesNibName
{
    NSString* ret = [self.bundle objectForInfoDictionaryKey:@"NSMainNibFile"];
    if(ret)
        return ret;
    return @"Main";
}

- (NSView *)preferencesView
{
    return preferencesView;
}

- (void)setPreferencesView:(NSView *)view
{
    [preferencesView release];
    preferencesView = [view retain];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@: %@", NSStringFromClass([self class]), [self identifier]];
}

#pragma mark private methods

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
    return [self.bundle unload];
}

@end
