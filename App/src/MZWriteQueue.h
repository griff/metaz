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
    NSMutableArray* queue;
    RunStatus status;
}
@property(readonly) BOOL started;
@property(readonly) BOOL paused;
@property(readonly) NSArray* queue;

+(MZWriteQueue *)sharedQueue;

-(void)start;
-(void)pause;
-(void)resume;
-(void)stop;
-(void)removeAllObjects;
-(BOOL)loadQueueWithError:(NSError **)error;
-(BOOL)saveQueueWithError:(NSError **)error;
-(void)addArrayToQueue:(NSArray *)anArray;
-(void)addObjectToQueue:(MetaEdits *)anEdit;

@end
