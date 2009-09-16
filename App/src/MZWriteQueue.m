//
//  MZWriteQueue.m
//  MetaZ
//
//  Created by Brian Olsen on 07/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "MZWriteQueue.h"

@implementation MZWriteQueue
@synthesize queue;

static MZWriteQueue* sharedQueue = nil;

+(MZWriteQueue *)sharedQueue {
    if(!sharedQueue)
        [[[MZWriteQueue alloc] init] release];
    return sharedQueue;
}

-(id)init
{
    self = [super init];

    if(sharedQueue)
    {
        [self release];
        self = [sharedQueue retain];
    } else if(self)
    {
        status = QueueStopped;
        fileName = [[@"MetaZ" stringByAppendingPathComponent:@"Write.queue"] retain];
        queue = [[NSMutableArray alloc] init];
        //[self loadQueueWithError:NULL];
        sharedQueue = [self retain];
    }
    return self;
}

-(void)dealloc
{
    [fileName release];
    [queue release];
    [super dealloc];
}

-(BOOL)started
{
    return status > QueueStopped;
}

-(BOOL)paused
{
    return status == QueuePaused;
}

-(void)start
{
    if(status == QueueStopped)
        status = QueueRunning;
}

-(void)pause
{
    if(status == QueueRunning)
        status = QueuePaused;
}

-(void)resume
{
    if(status == QueuePaused)
        status = QueueRunning;
}

-(void)stop
{
    if(status != QueueStopped)
        status = QueueStopped;
}

-(BOOL)loadQueueWithError:(NSError **)error
{
    NSFileManager *mgr = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    for(NSString * path in paths)
    {
        NSString *destinationPath = [path stringByAppendingPathComponent: fileName];
        if([mgr fileExistsAtPath:destinationPath])
        {
            id ret = [NSKeyedUnarchiver unarchiveObjectWithFile:destinationPath];
            if(!ret)
            {
                // Make NSError;
                return NO;
            }
            [self willChangeValueForKey:@"queue"];
            [queue addObjectsFromArray: ret];
            [self didChangeValueForKey:@"queue"];
            return YES;
        }
    }
    if ([paths count] == 0)
    {
        //Make NSError;
        return NO;
    }
    return YES;
}

-(BOOL)saveQueueWithError:(NSError **)error
{
    NSFileManager *mgr = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    if([queue count] > 0)
    {
        if ([paths count] > 0)
        {
            NSString *destinationDir = [[paths objectAtIndex:0]
                        stringByAppendingPathComponent: @"MetaZ"];
            BOOL isDir;
            if([mgr fileExistsAtPath:destinationDir isDirectory:&isDir])
            {
                if(!isDir)
                {
                    [mgr removeItemAtPath:destinationDir error:error];
                    [mgr createDirectoryAtPath:destinationDir withIntermediateDirectories:YES attributes:nil error:error];
                }
            }
            else
                [mgr createDirectoryAtPath:destinationDir withIntermediateDirectories:YES attributes:nil error:error];
            
            NSString *destinationPath = [[paths objectAtIndex:0]
                        stringByAppendingPathComponent: fileName];
            if(![NSKeyedArchiver archiveRootObject:queue toFile:destinationPath])
            {
                //Make NSError;
                return NO;
            }
        }
        else
        {
            // Make NSError;
            return NO;
        }
    }
    else
    {
        for(NSString * path in paths)
        {
            NSString *destinationPath = [path stringByAppendingPathComponent: fileName];
            if([mgr fileExistsAtPath:destinationPath] && ![mgr removeItemAtPath:destinationPath error:error])
                return NO;
        }
    }
    return YES;
}

-(void)removeAllObjects
{
    [self willChangeValueForKey:@"queue"];
    [queue removeAllObjects];
    [self didChangeValueForKey:@"queue"];
}

-(void)addArrayToQueue:(NSArray *)anArray
{
    [self willChangeValueForKey:@"queue"];
    for(MetaEdits* edit in anArray)
        [queue addObject:[edit copy]];
    [self saveQueueWithError:NULL];
    [self didChangeValueForKey:@"queue"];
}

-(void)addObjectToQueue:(MetaEdits *)anEdit
{
    [self willChangeValueForKey:@"queue"];
    [queue addObject:[anEdit copy]];
    [self saveQueueWithError:NULL];
    [self didChangeValueForKey:@"queue"];
}

@end
