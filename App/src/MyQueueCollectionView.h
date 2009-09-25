//
//  MyQueueCollectionView.h
//  MetaZ
//
//  Created by Brian Olsen on 22/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MGCollectionView.h"

@interface MyQueueCollectionView : MGCollectionView {
    NSArrayController* queues;
}
@property(nonatomic, retain) IBOutlet NSArrayController* queues;

-(void)removeObject:(id)object;

@end
