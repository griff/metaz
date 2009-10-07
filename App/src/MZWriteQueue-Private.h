/*
 *  MZWriteQueue-Private.h
 *  MetaZ
 *
 *  Created by Brian Olsen on 04/10/09.
 *  Copyright 2009 Maven-Group. All rights reserved.
 *
 */


@interface MZWriteQueue (Private)
@property(readonly) BOOL hasNextItem;

- (void)startNextItem;

@end
