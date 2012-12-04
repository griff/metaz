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

- (id)init
{
    self = [super init];
    if(self)
    {
        bundle = [[NSBundle bundleForClass:[self class]] retain];
    }
    return self;
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

- (NSArray *)dataProviders
{
    return [NSArray array];
}

- (NSArray *)searchProviders
{
    return [NSArray array];
}

- (NSString *)label
{
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
                      bundle:bundle];
        if(!nib)
            return nil;
        
        NSArray* theTopLevelObjects = nil;
        if([nib instantiateNibWithOwner:self topLevelObjects:&theTopLevelObjects])
            topLevelObjects = [theTopLevelObjects retain];
    }
    return [self preferencesView];
}

- (NSString *)preferencesNibName
{
    NSString* ret = [bundle objectForInfoDictionaryKey:@"NSMainNibFile"];
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

@end
