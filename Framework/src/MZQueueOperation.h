//
//  MZQueueOperation.h
//  MetaZ
//
//  Created by Brian Olsen on 19/01/10.
//  Copyright 2010 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MZQueueOperation : NSOperation
{
    NSOperationQueue* queue;
    NSArray* operations;
    BOOL isExecuting;
    BOOL isFinished;
}
@property(readonly,copy) NSArray* operations;
@property(assign) BOOL isExecuting;
@property(assign) BOOL isFinished;

- (void)addOperation:(NSOperation *)operation;
- (void)removeOperation:(NSOperation *)operation;

- (void)start;
- (BOOL)isConcurrent;
- (void)cancel;

@end
