//
//  MZQueueOperation.m
//  MetaZ
//
//  Created by Brian Olsen on 19/01/10.
//  Copyright 2010 Maven-Group. All rights reserved.
//

#import "MZQueueOperation.h"
#import "GTMNSObject+KeyValueObserving.h"

@interface MZQueueOperation ()
@property(readwrite,copy) NSArray* operations;

- (void)operationFinished:(GTMKeyValueChangeNotification *)notification;
@end

@implementation MZQueueOperation

+ (NSSet *)keyPathsForValuesAffectingIsFinished
{
    return [NSSet setWithObjects:@"finished", nil];
}

+ (NSSet *)keyPathsForValuesAffectingIsExecuting
{
    return [NSSet setWithObjects:@"executing", nil];
}

- (id)init
{
    self = [super init];
    if(self)
    {
        operations = [[NSArray alloc] init];
        queue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)dealloc
{
    for(NSOperation* op in operations)
        [op gtm_removeObserver:self forKeyPath:@"isFinished" selector:@selector(operationFinished:)];
    [operations release];
    [queue release];
    [super dealloc];
}

@synthesize operations;
@synthesize executing;
@synthesize finished;

- (void)addOperation:(NSOperation *)operation
{
    @synchronized(self)
    {
        [operation gtm_addObserver:self forKeyPath:@"isFinished" selector:@selector(operationFinished:) userInfo:nil options:0];
        if(self.executing)
        {
            if([self isCancelled])
                [operation cancel];
            else
                [queue addOperation:operation];
        }
        operations = [operations arrayByAddingObject:operation];
    }
}

- (void)removeOperation:(NSOperation *)operation
{
    [operation gtm_removeObserver:self forKeyPath:@"isFinished" selector:@selector(operationFinished:)];
    NSMutableArray* ops = [NSMutableArray arrayWithArray:self.operations];
    [ops removeObject:operation];
    self.operations = ops;
    
    [self operationFinished:nil];
}

- (void)start
{
    if([self isCancelled])
    {
        for(NSOperation* op in self.operations)
            [op cancel];
        self.finished = YES;
        return;
    }
    self.executing = YES;
    for(NSOperation* op in self.operations)
        [queue addOperation:op];

    [self operationFinished:nil];
}

- (BOOL)isConcurrent
{
    return YES;
}

- (void)cancel
{
    [super cancel];
    [queue cancelAllOperations];
}

- (void)operationFinished:(GTMKeyValueChangeNotification *)notification
{
    @synchronized(self)
    {
        if(!self.executing)
            return;
        for(NSOperation* op in self.operations)
            if(![op isFinished])
                return;
        self.executing = NO;
        self.finished = YES;
    }
}

@end
