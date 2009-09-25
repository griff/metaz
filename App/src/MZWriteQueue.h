//
//  MZWriteQueue.h
//  MetaZ
//
//  Created by Brian Olsen on 07/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MetaEdits.h"

typedef enum {
    QueueStopped,
    QueueRunning,
    QueuePaused
} RunStatus;

@interface MZWriteQueue : NSObject {
    NSString* fileName;
    NSMutableArray* queueItems;
    RunStatus status;
}
@property(readonly) BOOL started;
@property(readonly) BOOL paused;
@property(readonly) NSArray* queueItems;
@property(readonly) RunStatus status;

+ (MZWriteQueue *)sharedQueue;
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key;

-(void)start;
-(void)pause;
-(void)resume;
-(void)stop;
-(BOOL)loadQueueWithError:(NSError **)error;
-(BOOL)saveQueueWithError:(NSError **)error;
-(void)removeAllQueueItems;
-(void)removeObjectFromQueueItemsAtIndex:(NSUInteger)index;
-(void)removeQueueItemsAtIndexes:(NSIndexSet *)indexes;
-(void)insertObject:(MetaEdits *)anEdit inQueueItemsAtIndex:(NSUInteger)index;
-(void)insertQueueItems:(NSArray *)edits atIndexes:(NSIndexSet *)indexes;
-(void)addQueueItems:(NSArray *)anArray;
-(void)addQueueItemsObject:(MetaEdits *)anEdit;

@end
