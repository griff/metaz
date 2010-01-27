//
//  MZErrorOperation.m
//  MetaZ
//
//  Created by Brian Olsen on 19/01/10.
//  Copyright 2010 Maven-Group. All rights reserved.
//

#import "MZErrorOperation.h"
#import "GTMNSObject+KeyValueObserving.h"

@implementation MZErrorOperation

- (void)dealloc
{
    for(NSOperation* op in [self dependencies])
        if([op isKindOfClass:[MZErrorOperation class]])
            [op gtm_removeObserver:self forKeyPath:@"error" selector:@selector(errorChanged:)];
    [error release];
    [super dealloc];
}

@synthesize error;

- (void)addDependency:(NSOperation *)op
{
    if([op isKindOfClass:[MZErrorOperation class]])
        [op gtm_addObserver:self forKeyPath:@"error" selector:@selector(errorChanged:) userInfo:nil options:0];
    [super addDependency:op];
}

- (void)removeDependency:(NSOperation *)op
{
    if([op isKindOfClass:[MZErrorOperation class]])
        [op gtm_removeObserver:self forKeyPath:@"error" selector:@selector(errorChanged:)];
    [super removeDependency:op];
}

- (void)dependency:(NSOperation *)op failedWithError:(NSError*)theError
{
    self.error = theError;
    [self cancel];
}

- (void)errorChanged:(GTMKeyValueChangeNotification *)notification
{
    MZErrorOperation* op = [notification object];
    [self dependency:op failedWithError:op.error];
}

@end
