//
//  NSFileManager+MZCreate.m
//  MetaZ
//
//  Created by Brian Olsen on 09/04/10.
//  Copyright 2010 Maven-Group. All rights reserved.
//

#import "NSFileManager+MZCreate.h"


@implementation NSFileManager (MZCreate)

+(NSFileManager *)manager
{
    return [[[self alloc] init] autorelease];
}

@end
