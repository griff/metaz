//
//  NSString+MZAllInCharacterSet.m
//  MetaZ
//
//  Created by Brian Olsen on 08/08/11.
//  Copyright 2011 Maven-Group. All rights reserved.
//

#import "NSString+MZAllInCharacterSet.h"


@implementation NSString (MZAllInCharacterSet)

- (BOOL)mz_allInCharacterSet:(NSCharacterSet *)set;
{
    int length = [self length];
    for(NSUInteger i=0; i<length;i++)
    {
        unichar ch = [self characterAtIndex:i];
        if(![set characterIsMember:ch])
            return NO;
    }
    return YES;
}

@end
