//
//  MZPriorObserverFix.m
//  MetaZ
//
//  Created by Brian Olsen on 15/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "MZPriorObserverFix.h"


@implementation MZPriorObserverFix

+ (id)fixWithOther:(id)other
{
    return [[[self alloc] initWithOther:other] autorelease];
}

+ (id)fixWithOther:(id)other prefix:(NSString *)prefix
{
    return [[[self alloc] initWithOther:other prefix:prefix] autorelease];
}

- (id)initWithOther:(id)theOther
{
    return [self initWithOther:theOther prefix:nil];
}

- (id)initWithOther:(id)theOther prefix:(NSString *)value
{
    self = [super init];
    if(self)
    {
        prefix = [value retain];
        oldData = [[NSMutableDictionary alloc] init];
        keyPathCount = [[NSMutableDictionary alloc] init];
        other = [theOther retain];
    }
    return self;
}

- (void)dealloc
{
    for(NSString* key in [keyPathCount allKeys])
    {
        NSString* key2 = [key stringByAppendingString:@".self"];
        if(prefix)
            key2 = [prefix stringByAppendingString:key];
        [other removeObserver:self forKeyPath:key2];
    }
    [other release];
    [prefix release];
    [oldData release];
    [keyPathCount release];
    [super dealloc];
}

- (void)addObserver:(NSObject *)observer
         forKeyPath:(NSString *)keyPath
            options:(NSKeyValueObservingOptions)options
            context:(void *)context
{
    NSString* key;
    NSRange range = [keyPath rangeOfString:@"."];
    if(range.location != NSNotFound)
        key = [keyPath substringToIndex:range.location];
    else
        key = keyPath;
        
    NSString *key2 = [key stringByAppendingString:@".self"];
    if(prefix)
        key2 = [prefix stringByAppendingString:key];
            
    id oldValue = [other valueForKeyPath:key2];
    if(oldValue == NSMultipleValuesMarker)
    {
        NSString* newPrefix = [key stringByAppendingString:@"."];
        if(prefix)
        {
            newPrefix = [prefix stringByAppendingString:newPrefix];
        } else
            oldValue = [MZPriorObserverFix fixWithOther:other prefix:newPrefix];
    }
    if(oldValue)
        [oldData setObject:oldValue forKey:key];
    NSInteger count = [[keyPathCount objectForKey:key] integerValue];
    count++;
    [keyPathCount setObject:[NSNumber numberWithInteger:count] forKey:key];

    if(count == 1)
    {
        [other addObserver:self forKeyPath:key2 options:0 context:NULL];
    }

    [super addObserver:observer forKeyPath:keyPath options:options context:context];
}

- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath
{
    NSString* key;
    NSRange range = [keyPath rangeOfString:@"."];
    if(range.location != NSNotFound)
        key = [keyPath substringToIndex:range.location];
    else
        key = keyPath;
        
    NSString* key2 = [key stringByAppendingString:@".self"];
    if(prefix)
        key2 = [prefix stringByAppendingString:key];

    NSInteger count = [[keyPathCount objectForKey:key] integerValue];
    count--;

    if(count == 0)
    {
        [other removeObserver:self forKeyPath:key2];
        [keyPathCount removeObjectForKey:key];
    }
    else
        [keyPathCount setObject:[NSNumber numberWithInteger:count] forKey:key];

    [super removeObserver:observer forKeyPath:keyPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSString* shortPath = keyPath;
    if(prefix)
        shortPath = [keyPath substringFromIndex:[prefix length]];
    NSString* key;
    NSRange range = [shortPath rangeOfString:@"."];
    if(range.location != NSNotFound)
        key = [shortPath substringToIndex:range.location];
    else
        key = shortPath;
    
    if(prefix)
        NSLog(@"We changed");

    [self retain];
    id oldValue = [[oldData objectForKey:key] retain];
    [self willChangeValueForKey:key];
    id newValue = [other valueForKeyPath:keyPath];
    if(newValue == NSMultipleValuesMarker)
    {
        //newValue = [other valueForKey:key];
        NSString* newPrefix = [key stringByAppendingString:@"."];
        if(prefix)
        {
            newPrefix = [prefix stringByAppendingString:newPrefix];
        }
        else
            newValue = [MZPriorObserverFix fixWithOther:other prefix:newPrefix];
    }
    if(newValue)
        [oldData setObject:newValue forKey:key];
    else
        [oldData removeObjectForKey:key];
    [self didChangeValueForKey:key];
    [self autorelease];
    [oldValue autorelease];
}

- (id)valueForUndefinedKey:(NSString *)key
{
    id ret = [oldData objectForKey:key];
    return ret;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if(prefix)
        [other setValue:value forKeyPath:[prefix stringByAppendingString:key]];
    else
        [other setValue:value forKey:key];
}


@end
