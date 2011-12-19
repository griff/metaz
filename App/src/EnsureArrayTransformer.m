//
//  EnsureArrayTransformer.m
//  MetaZ
//
//  Created by Brian Olsen on 18/12/11.
//  Copyright 2011 Maven-Group. All rights reserved.
//

#import "EnsureArrayTransformer.h"


@implementation EnsureArrayTransformer

+ (Class)transformedValueClass
{
    return [NSArray class];
}

+ (BOOL)allowsReverseTransformation; { return NO; }

- (id)transformedValue:(id)value
{
    if(value == nil) return [NSArray array];
    if([value isKindOfClass:[NSArray class]])
    {
        NSLog(@"Transforming %d", [value count]);
        return value;
    }
    return [NSArray arrayWithObject:value];
}

@end
