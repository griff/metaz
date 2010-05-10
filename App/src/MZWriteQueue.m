//
//  MZWriteQueue.m
//  MetaZ
//
//  Created by Brian Olsen on 07/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "MZWriteQueue.h"
#import "MZWriteQueue+Private.h"
#import "MZWriteQueueStatus.h"
#import "MZWriteQueueStatus+Private.h"
#import "NSUserDefaults+KeyPath.h"

@implementation MZWriteQueue
@synthesize queueItems;
@synthesize status;
@synthesize removeWhenTrashFailes;

static MZWriteQueue* sharedQueue = nil;

+(MZWriteQueue *)sharedQueue {
    if(!sharedQueue)
        [[[MZWriteQueue alloc] init] release];
    return sharedQueue;
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    return !([key isEqual:@"queueItems"] || [key isEqual:@"status"]);
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    NSSet* sup = [super keyPathsForValuesAffectingValueForKey:key];
    if([key isEqualToString:@"pendingItems"] ||
        [key isEqualToString:@"completedItems"])
    {
        return [sup setByAddingObject:@"queueItems"];
    }
    return sup;
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
        queueItems = [[NSMutableArray alloc] init];
        //[self loadQueueWithError:NULL];
        sharedQueue = [self retain];
        [self resetTrashHandling];
    }
    return self;
}

-(void)dealloc
{
    [fileName release];
    [queueItems release];
    [super dealloc];
}

- (void)resetTrashHandling
{
    removeWhenTrashFailes = (int)[[NSUserDefaults standardUserDefaults] 
        integerForKey:@"actionWhenTrashFailes"
              default:PromptForTrashHandling];
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
    {
        [self willChangeValueForKey:@"status"];
        status = QueueRunning;
        [self didChangeValueForKey:@"status"];
        [[NSNotificationCenter defaultCenter]
                postNotificationName:MZQueueStarted
                              object:self];
        
        [self startNextItem];
    }
}

/*
-(void)pause
{
    if(status == QueueRunning)
    {
        [self willChangeValueForKey:@"status"];
        status = QueuePaused;
        [self didChangeValueForKey:@"status"];
    }
}

-(void)resume
{
    if(status == QueuePaused)
    {
        [self willChangeValueForKey:@"status"];
        status = QueueRunning;
        [self didChangeValueForKey:@"status"];
    }
}
*/

-(void)stop
{
    if(status != QueueStopped && status != QueueStopping )
    {
        [self willChangeValueForKey:@"status"];
        status = QueueStopping;
        stopWaitCount = 0;
        for(MZWriteQueueStatus* sts in queueItems)
        {
            if([sts stopWriting])
                stopWaitCount++;
        }
        if(stopWaitCount==0)
        {
            status = QueueStopped;
            for(MZWriteQueueStatus* sts in queueItems)
            {
                if(sts.hasRun && !sts.completed)
                    sts.hasRun = NO;
            }
            [self saveQueueWithError:NULL];
        }
        [self resetTrashHandling];
        [self didChangeValueForKey:@"status"];
    }
}

- (BOOL)hasNextItem
{
    for(id obj in queueItems)
        if([obj writing] == 0 && ![obj hasRun])
            return YES;
    return NO;
}

- (void)startNextItem
{
    MZWriteQueueStatus* sts = nil;
    int len = [queueItems count];
    for(int i=0; i<len; i++)
    {
        sts = [queueItems objectAtIndex:i];
        if(![sts hasRun])
        {
            [self willChangeValueForKey:@"pendingItems"];
            [sts startWriting];
            [self didChangeValueForKey:@"pendingItems"];
            [self saveQueueWithError:NULL];
            return;
        }
    }
    [self stop];
    [self saveQueueWithError:NULL];
    [[NSNotificationCenter defaultCenter]
            postNotificationName:MZQueueCompleted
                          object:self];
}

- (void)itemStopped
{
    if(status == QueueStopping)
    {
        stopWaitCount--;
        if(stopWaitCount == 0)
        {
            [self willChangeValueForKey:@"status"];
            status = QueueStopped;
            [self didChangeValueForKey:@"status"];

            for(MZWriteQueueStatus* sts in queueItems)
            {
                if(sts.hasRun && !sts.completed)
                    sts.hasRun = NO;
            }
            [self saveQueueWithError:NULL];
        }
    }
}


-(BOOL)loadQueueWithError:(NSError **)error
{
    NSFileManager *mgr = [NSFileManager manager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    for(NSString * path in paths)
    {
        NSString *destinationPath = [path stringByAppendingPathComponent: fileName];
        if([mgr fileExistsAtPath:destinationPath])
        {
            id ret = [NSKeyedUnarchiver unarchiveObjectWithFile:destinationPath];
            if(!ret)
            {
                if(error != NULL)
                {
                    //Make NSError;
                    NSDictionary* dict = [NSDictionary dictionaryWithObject:
                        NSLocalizedString(@"Unarchiving of queue items failed", @"Unarchiving error")
                        forKey:NSLocalizedDescriptionKey];
                    *error = [NSError errorWithDomain:@"MetaZ" code:12 userInfo:dict];
                }
                return NO;
            }
            [self willChangeValueForKey:@"queueItems"];
            for(MetaEdits* edits in ret)
                [queueItems addObject:[MZWriteQueueStatus statusWithEdits:edits]];
            [self didChangeValueForKey:@"queueItems"];
            return YES;
        }
    }
    if ([paths count] == 0)
    {
        if(error != NULL)
        {
            //Make NSError;
            NSDictionary* dict = [NSDictionary dictionaryWithObject:
                NSLocalizedString(@"No search paths found", @"Search path error")
                forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:@"MetaZ" code:10 userInfo:dict];
        }
        return NO;
    }
    return YES;
}

-(BOOL)saveQueueWithError:(NSError **)error
{
    NSFileManager *mgr = [NSFileManager manager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSMutableArray* items = [NSMutableArray array];
    for(MZWriteQueueStatus* obj in queueItems)
        if(![obj completed])
            [items addObject:[obj edits]];
    if([items count] > 0)
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
            if(![NSKeyedArchiver archiveRootObject:items toFile:destinationPath])
            {
                if(error != NULL)
                {
                    //Make NSError;
                    NSDictionary* dict = [NSDictionary dictionaryWithObject:
                        NSLocalizedString(@"Archiving of queue items failed", @"Archiving error")
                        forKey:NSLocalizedDescriptionKey];
                    *error = [NSError errorWithDomain:@"MetaZ" code:11 userInfo:dict];
                }
                return NO;
            }
        }
        else
        {
            if(error != NULL)
            {
                //Make NSError;
                NSDictionary* dict = [NSDictionary dictionaryWithObject:
                    NSLocalizedString(@"No search paths found", @"Search path error")
                    forKey:NSLocalizedDescriptionKey];
                *error = [NSError errorWithDomain:@"MetaZ" code:10 userInfo:dict];
            }
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

- (NSArray *)pendingItems
{
    NSMutableArray* ret = [NSMutableArray array];
    for(id obj in queueItems)
        if([obj writing] == 0 && ![obj hasRun])
            [ret addObject:obj];
    return ret;
}

- (NSArray *)completedItems
{
    NSMutableArray* ret = [NSMutableArray array];
    for(id obj in queueItems)
        if([obj completed])
            [ret addObject:obj];
    return ret;
}


- (void)removeCompleted:(id)sender
{
    [self willChangeValueForKey:@"queueItems"];
    NSMutableIndexSet* set = [[NSMutableIndexSet alloc] init];
    int len = [queueItems count];
    for(int i=0; i<len; i++)
    {
        if([[queueItems objectAtIndex:i] completed])
            [set addIndex:i];
    }
    [queueItems removeObjectsAtIndexes:set];
    [set release];
    [self didChangeValueForKey:@"queueItems"];
}

-(void)removeAllQueueItems
{
    [self willChangeValueForKey:@"queueItems"];
    [queueItems removeAllObjects];
    [self saveQueueWithError:NULL];
    [self didChangeValueForKey:@"queueItems"];
}

- (void)removeObjectFromQueueItems:(id)object
{
    [self willChangeValueForKey:@"queueItems"];
    [queueItems removeObject:object];
    [self saveQueueWithError:NULL];
    [self didChangeValueForKey:@"queueItems"];
}

-(void)removeObjectFromQueueItemsAtIndex:(NSUInteger)index
{
    [self willChangeValueForKey:@"queueItems"];
    [queueItems removeObjectAtIndex:index];
    [self saveQueueWithError:NULL];
    [self didChangeValueForKey:@"queueItems"];
}

-(void)removeQueueItemsAtIndexes:(NSIndexSet *)indexes
{
    [self willChangeValueForKey:@"queueItems"];
    [queueItems removeObjectsAtIndexes:indexes];
    [self saveQueueWithError:NULL];
    [self didChangeValueForKey:@"queueItems"];
}

-(void)insertObject:(MetaEdits *)anEdit inQueueItemsAtIndex:(NSUInteger)index
{
    NSAssert(anEdit, @"A value argument");
    [self willChangeValueForKey:@"queueItems"];
    [queueItems insertObject:[MZWriteQueueStatus statusWithEdits:anEdit] atIndex:index];
    [self saveQueueWithError:NULL];
    [self didChangeValueForKey:@"queueItems"];
}

-(void)insertQueueItems:(NSArray *)edits atIndexes:(NSIndexSet *)indexes;
{
    NSUInteger currentIndex = [indexes firstIndex];
    NSUInteger i, count = [indexes count];
    NSAssert([edits count] == count, @"Array and indexes must contain same count");
 
    [self willChangeValueForKey:@"queueItems"];
    for (i = 0; i < count; i++)
    {
        MetaEdits* edit = [edits objectAtIndex:i];
        [queueItems insertObject:[MZWriteQueueStatus statusWithEdits:edit] atIndex:currentIndex];
        currentIndex = [indexes indexGreaterThanIndex:currentIndex];
    }
    [self saveQueueWithError:NULL];
    [self didChangeValueForKey:@"queueItems"];
}

-(void)addQueueItems:(NSArray *)anArray
{
    NSAssert(anArray, @"An array argument");
    if([anArray count] == 0)
        return;
    [self willChangeValueForKey:@"queueItems"];
    for(MetaEdits* edit in anArray)
    {
        [queueItems addObject:[MZWriteQueueStatus statusWithEdits:edit]];
    }
    [self saveQueueWithError:NULL];
    [self didChangeValueForKey:@"queueItems"];
}

-(void)addQueueItemsObject:(MetaEdits *)anEdit
{
    NSAssert(anEdit, @"A value argument");
    [self willChangeValueForKey:@"queueItems"];
    [queueItems addObject:[MZWriteQueueStatus statusWithEdits:anEdit]];
    [self saveQueueWithError:NULL];
    [self didChangeValueForKey:@"queueItems"];
}

@end
