//
//  MZWriteQueue.m
//  MetaZ
//
//  Created by Brian Olsen on 07/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "MZWriteQueue.h"

@interface MZWriteQueue (Private)
- (void)registerAsObserver;
- (void)unregisterAsObserver;
@end

@implementation MZWriteQueue

-(id)init
{
    self = [super init];
    fileName = [[@"MetaZ" stringByAppendingPathComponent:@"Write.queue"] retain];
    queue = [[NSMutableArray alloc] init];
    return self;
}

-(void)dealloc
{
    [fileName release];
    [queue release];
}

- (void)applicationDidFinishLaunching:(NSNotification *)note
{
    [self loadQueueWithError:NULL];
    if([queue count] > 0)
    {
        //Make alert about reloading queue;
        if( NO )
        {
            [queue removeAllObjects];
        }
    }
}

- (void)registerAsObserver
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidFinishLaunching:) name:NSApplicationDidFinishLaunchingNotification object:NSApp];
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDriverDidFinish:) name:SUUpdateDriverFinishedNotification object:nil];
}

- (void)unregisterAsObserver
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(BOOL)loadQueueWithError:(NSError **)error
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    for(NSString * path in paths)
    {
        NSString *destinationPath = [path stringByAppendingPathComponent: fileName];
        if([mgr fileExistsAtPath:destinationPath])
        {
            id ret = [NSKeyedUnarchiver unarchiveObjectWithFile:fileName];
            if(!ret)
            {
                // Make NSError;
                return NO;
            }
            [queue addObjectsFromArray: ret];
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
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    if([queue count] > 0)
    {
        if ([paths count] > 0)
        {
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
        NSFileManager *mgr = [NSFileManager defaultManager];
        for(NSString * path in paths)
        {
            NSString *destinationPath = [path stringByAppendingPathComponent: fileName];
            if([mgr fileExistsAtPath:destinationPath] && ![mgr removeItemAtPath:destinationPath error:error])
                return NO;
        }
    }
    return YES;
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
