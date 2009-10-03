//
//  MyQueueCollectionView.m
//  MetaZ
//
//  Created by Brian Olsen on 22/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "MyQueueCollectionView.h"
#import "MZWriteQueueStatus.h"

@implementation MyQueueCollectionView
@synthesize queues;

-(void)dealloc
{
    [queues release];
    [super dealloc];
}

/*
-(void)release
{
    NSUInteger count = [self retainCount];
    NSLog(@"Releasing CollectionView %d", count);
    [super release];
}

- (id)retain
{
    NSUInteger count = [self retainCount];
    NSLog(@"Retaining CollectionView %d", count);
    return [super retain];
}
*/

-(void)awakeFromNib
{
    [self bind:NSContentBinding toObject:queues withKeyPath:@"arrangedObjects" options:nil];
    
}

-(void)removeObject:(id)object
{
    [object stopWritingAndRemove];
}

@end
