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

- (id)initWithOther:(id)theOther
{
    self = [super init];
    if(self)
    {
        oldData = [[NSMutableDictionary alloc] init];
        keyPathCount = [[NSMutableDictionary alloc] init];
        other = [theOther retain];
    }
    return self;
}

- (void)dealloc
{
    for(NSString* keyPath in [keyPathCount allKeys])
        [other removeObserver:self forKeyPath:keyPath];
    [oldData release];
    [keyPathCount release];
    [other release];
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
            
    id oldValue = [other valueForKey:key];
    if(oldValue)
        [oldData setObject:oldValue forKey:key];
    NSInteger count = [[keyPathCount objectForKey:key] integerValue];
    count++;
    [keyPathCount setObject:[NSNumber numberWithInteger:count] forKey:key];

    if(count == 1)
        [other addObserver:self forKeyPath:key options:(options & ~NSKeyValueObservingOptionPrior) context:NULL];

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

    NSInteger count = [[keyPathCount objectForKey:key] integerValue];
    count--;

    if(count == 0)
    {
        [other removeObserver:self forKeyPath:key];
        [keyPathCount removeObjectForKey:key];
    }
    else
        [keyPathCount setObject:[NSNumber numberWithInteger:count] forKey:key];

    [super removeObserver:observer forKeyPath:keyPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSString* key;
    NSRange range = [keyPath rangeOfString:@"."];
    if(range.location != NSNotFound)
        key = [keyPath substringToIndex:range.location];
    else
        key = keyPath;

    [self willChangeValueForKey:key];
    id newValue = [other valueForKey:key];
    if(newValue)
        [oldData setObject:newValue forKey:key];
    else
        [oldData removeObjectForKey:key];
    [self didChangeValueForKey:key];
}

- (id)valueForUndefinedKey:(NSString *)key
{
    return [oldData objectForKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    [other setValue:value forKey:key];
}


@end
