//
//  NSArray-Mapping.m
//  MetaZ
//
//  Created by Brian Olsen on 25/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "NSArray+Mapping.h"
#import "NSObject+ProtectedKeyValue.h"

@implementation NSArray (Mapping)

- (NSArray *)arrayByPerformingSelector:(SEL)aSelector
{
    NSMutableArray* ret = [NSMutableArray arrayWithCapacity:[self count]];
    for(id obj in self)
    {
        obj = [obj performSelector:aSelector];
        if(!obj)
            obj = [NSNull null];
        [ret addObject:obj];
    }
    return [NSArray arrayWithArray:ret];
}

- (NSArray *)arrayByPerformingSelector:(SEL)aSelector withObject:(id)anObject
{
    NSMutableArray* ret = [NSMutableArray arrayWithCapacity:[self count]];
    for(id obj in self)
    {
        obj = [obj performSelector:aSelector withObject:anObject];
        if(!obj)
            obj = [NSNull null];
        [ret addObject:obj];
    }
    return [NSArray arrayWithArray:ret];
}

- (NSArray *)arrayByPerformingKey:(NSString *)key
{
    NSMutableArray* ret = [NSMutableArray arrayWithCapacity:[self count]];
    for(id obj in self)
    {
        obj = [obj valueForKey:key];
        if(!obj)
            obj = [NSNull null];
        [ret addObject:obj];
    }
    return [NSArray arrayWithArray:ret];
}

- (NSArray *)arrayByPerformingKeyPath:(NSString *)keyPath
{
    NSMutableArray* ret = [NSMutableArray arrayWithCapacity:[self count]];
    for(id obj in self)
    {
        obj = [obj valueForKeyPath:keyPath];
        if(!obj)
            obj = [NSNull null];
        [ret addObject:obj];
    }
    return [NSArray arrayWithArray:ret];
}


- (NSArray *)arrayByPerformingProtectedKey:(NSString *)key
{
    NSMutableArray* ret = [NSMutableArray arrayWithCapacity:[self count]];
    for(id obj in self)
    {
        obj = [obj protectedValueForKey:key];
        if(!obj)
            obj = [NSNull null];
        [ret addObject:obj];
    }
    return [NSArray arrayWithArray:ret];
}

- (NSArray *)arrayByPerformingProtectedKeyPath:(NSString *)keyPath
{
    NSMutableArray* ret = [NSMutableArray arrayWithCapacity:[self count]];
    for(id obj in self)
    {
        obj = [obj protectedValueForKeyPath:keyPath];
        if(!obj)
            obj = [NSNull null];
        [ret addObject:obj];
    }
    return [NSArray arrayWithArray:ret];
}
@end
