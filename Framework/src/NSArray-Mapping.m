//
//  NSArray-Mapping.m
//  MetaZ
//
//  Created by Brian Olsen on 25/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "NSArray-Mapping.h"


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

@end
