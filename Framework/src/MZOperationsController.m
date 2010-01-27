//
//  MZOperationsController.m
//  MetaZ
//
//  Created by Brian Olsen on 19/01/10.
//  Copyright 2010 Maven-Group. All rights reserved.
//

#import "MZOperationsController.h"
#import "GTMNSObject+KeyValueObserving.h"
#import "MZErrorOperation.h"

@interface MZOperationsController ()
@property(readwrite,copy) NSArray* operations;

- (void)operationFinished:(GTMKeyValueChangeNotification *)notification;
@end


@implementation MZOperationsController

- (id)init
{
    self = [super init];
    if(self)
    {
        operations = [[NSArray alloc] init];
        isFinished = NO;
    }
    return self;
}

- (void)dealloc
{
    for(NSOperation* op in operations)
    {
        [op gtm_removeObserver:self forKeyPath:@"isFinished" selector:@selector(operationFinished:)];
        if([op isKindOfClass:[MZErrorOperation class]])
            [op gtm_removeObserver:self forKeyPath:@"error" selector:@selector(errorChanged:)];
    }
    [operations release];
    [super dealloc];
}

@synthesize operations;
@synthesize error;
@synthesize isFinished;
@synthesize isCancelled;

- (void)addOperation:(NSOperation *)operation
{
    @synchronized(self)
    {
        if([operation isKindOfClass:[MZErrorOperation class]])
            [operation gtm_addObserver:self forKeyPath:@"error" selector:@selector(errorChanged:) userInfo:nil options:0];
        [operation gtm_addObserver:self forKeyPath:@"isFinished" selector:@selector(operationFinished:) userInfo:nil options:0];
        if([self isCancelled])
            [operation cancel];
        NSArray* old = operations;
        operations = [[operations arrayByAddingObject:operation] retain];
        [old release];
    }
}

- (void)removeOperation:(NSOperation *)operation
{
    [operation gtm_removeObserver:self forKeyPath:@"isFinished" selector:@selector(operationFinished:)];
    if([operation isKindOfClass:[MZErrorOperation class]])
        [operation gtm_removeObserver:self forKeyPath:@"error" selector:@selector(errorChanged:)];
    NSMutableArray* ops = [NSMutableArray arrayWithArray:self.operations];
    [ops removeObject:operation];
    self.operations = ops;
    
    [self operationFinished:nil];
}

- (void)cancel
{
    self.isCancelled = YES;
    for(NSOperation* op in self.operations)
        [op cancel];
}

- (void)addOperationsToQueue:(NSOperationQueue*)queue
{
    for(NSOperation* op in self.operations)
        [queue addOperation:op];
}

- (void)operationFinished:(GTMKeyValueChangeNotification *)notification
{
    @synchronized(self)
    {
        for(NSOperation* op in self.operations)
            if(![op isFinished])
                return;
        self.isFinished = YES;
        [self performSelectorOnMainThread:@selector(operationsFinished) withObject:nil waitUntilDone:NO];
    }
}

- (void)errorChanged:(GTMKeyValueChangeNotification *)notification
{
    MZErrorOperation* op = [notification object];
    self.error = op.error;
}

- (void)operationsFinished
{
}

@end
