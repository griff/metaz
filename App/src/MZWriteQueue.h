//
//  MZWriteQueue.h
//  MetaZ
//
//  Created by Brian Olsen on 07/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/MetaZKit.h>

#define MZQueueStarted @"MZQueueStarted"
#define MZQueueCompletedPercent @"MZQueueCompletedPercent"
#define MZQueueItemCompleted @"MZQueueItemCompleted"
#define MZQueueItemFailed @"MZQueueItemFailed"
#define MZQueueCompleted @"MZQueueCompleted"

typedef enum {
    QueueStopped,
    QueueStopping,
    QueueRunning,
    QueuePaused
} RunStatus;

typedef enum {
    PromptForTrashHandling = 0,
    KeepTempFileTrashHandling,
    RemoveTrashFailedTrashHandling
} TrashHandling;

@interface MZWriteQueue : NSObject {
    NSString* fileName;
    NSMutableArray* queueItems;
    RunStatus status;
    TrashHandling removeWhenTrashFailes;
    int stopWaitCount;
}
@property(readonly) BOOL started;
@property(readonly) BOOL paused;
@property(readonly) NSArray* queueItems;
@property(readonly) RunStatus status;
@property(readonly) NSArray* pendingItems;
@property(readonly) NSArray* completedItems;
@property(readwrite) TrashHandling removeWhenTrashFailes;

+ (MZWriteQueue *)sharedQueue;
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key;

- (void)resetTrashHandling;
- (void)start;
//- (void)pause;
//- (void)resume;
- (void)stop;
- (BOOL)loadQueueWithError:(NSError **)error;
- (BOOL)saveQueueWithError:(NSError **)error;
- (void)removeCompleted:(id)sender;
- (void)removeAllQueueItems;
- (void)removeObjectFromQueueItems:(id)object;
- (void)removeObjectFromQueueItemsAtIndex:(NSUInteger)index;
- (void)removeQueueItemsAtIndexes:(NSIndexSet *)indexes;
- (void)insertObject:(MetaEdits *)anEdit inQueueItemsAtIndex:(NSUInteger)index;
- (void)insertQueueItems:(NSArray *)edits atIndexes:(NSIndexSet *)indexes;
- (void)addQueueItems:(NSArray *)anArray;
- (void)addQueueItemsObject:(MetaEdits *)anEdit;

@end
