//
//  MetaEditsUndoManager.m
//  MetaZ
//
//  Created by Brian Olsen on 18/11/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "MetaEditsUndoManager.h"


@implementation MetaEditsUndoManager

- (id)init
{
    self = [super init];
    if(self)
    {
        others = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [others release];
    [super dealloc];
}

- (void)addOther:(NSUndoManager *)other
{
    [others addObject:other];
}

- (void)removeOther:(NSUndoManager *)other
{
    [others removeObject:other];
}


@end
