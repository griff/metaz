//
//  NSString+MZRemoveString.m
//  MetaZ
//
//  Created by Brian Olsen on 14/01/11.
//  Copyright 2011 Maven-Group. All rights reserved.
//

#import "NSString+MZRemoveString.h"


@implementation NSString (MZRemoveString)

- (NSString *)mz_stringByRemovingSubstringInRange:(NSRange)range;
{
    /*
    NSUInteger len = [self length];
    if(range.location >= len || range.location+range.length > len )
    {
        NSRangeException
    }
    */
    if(range.location == 0)
        return [self substringFromIndex:range.length];
    if(range.location+range.length == len)
        return [self substringToIndex:range.location];
    
    return [[self substringToIndex:range.location] 
        stringByAppendingString:[self substringFromIndex:range.length];
}

@end
