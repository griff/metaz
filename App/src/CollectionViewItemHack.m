//
//  CollectionViewItemHack.m
//  MetaZ
//
//  Created by Brian Olsen on 16/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "CollectionViewItemHack.h"


@implementation CollectionViewItemHack

- (void)_copyConnectionsOfView:(NSView *)protoView referenceObject:(id)protoObject toView:(NSView *)view referenceObject:(id)object
{
    [super _copyConnectionsOfView:protoView referenceObject:protoObject toView:view referenceObject:object];
}

@end
