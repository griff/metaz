//
//  NSFileManager+MZAsync.m
//  MetaZ
//
//  Created by Brian Olsen on 07/01/10.
//  Copyright 2010 Maven-Group. All rights reserved.
//

#import "NSFileManager+MZAsync.h"
#import "MZConstants.h"

NSError* status2Error(OSStatus status)
{
    return [NSError errorWithDomain:@"OSStatus" code:status userInfo:nil];
}

void MZCopyFSPathFileOperationStatusProc (
        FSFileOperationRef fileOp,
        const char *currentItem,
        FSFileOperationStage stage,
        OSStatus status,
        CFDictionaryRef statusDictionary,
        void *info)
{
    MZAsyncOperation* op = (MZAsyncOperation*)info;
    NSString* strCurrentItem = [op.fileManager stringWithFileSystemRepresentation:currentItem length:strlen(currentItem)];
    NSError* error = status2Error(status);
    [op.fileManager asyncCopyOperation:op currentItem:strCurrentItem stage:stage error:error statusDictionary:(NSDictionary*)statusDictionary];
}

void MZMoveFSPathFileOperationStatusProc (
        FSFileOperationRef fileOp,
        const char *currentItem,
        FSFileOperationStage stage,
        OSStatus status,
        CFDictionaryRef statusDictionary,
        void *info)
{
    MZAsyncOperation* op = (MZAsyncOperation*)info;
    NSString* strCurrentItem = [op.fileManager stringWithFileSystemRepresentation:currentItem length:strlen(currentItem)];
    NSError* error = status2Error(status);
    [op.fileManager asyncMoveOperation:op currentItem:strCurrentItem stage:stage error:error statusDictionary:(NSDictionary*)statusDictionary];
}

@implementation MZAsyncOperation

- (id)initWithManager:(NSFileManager *)theFileManager;
{
    self = [super init];
    if(self)
    {
        fileManager = [theFileManager retain];
        operation = FSFileOperationCreate(kCFAllocatorDefault);
    }
    return self;
}

- (void)dealloc
{
    if(runLoop) CFRelease(runLoop);
    if(runLoopMode) CFRelease(runLoopMode);
    CFRelease(operation);
    [fileManager release];
    [super dealloc];
}

@synthesize fileManager;
@synthesize operation;

- (OSStatus)schedule
{
    if(runLoop)
        [self unschedule];
    runLoop = (CFRunLoopRef)CFRetain(CFRunLoopGetCurrent());
    runLoopMode = CFRetain(kCFRunLoopCommonModes);
    return FSFileOperationScheduleWithRunLoop(operation, runLoop, runLoopMode);
}

- (OSStatus)unschedule
{
    OSStatus status = FSFileOperationUnscheduleFromRunLoop(operation, runLoop, runLoopMode);
    CFRelease(runLoop);
    runLoop = NULL;
    CFRelease(runLoopMode);
    runLoopMode = NULL;
    return status;
}

- (OSStatus)cancel
{
    return FSFileOperationCancel(operation);
}

@end


@implementation NSFileManager (MZAsync)

- (MZAsyncOperation*)copyItemAsyncAtPath:(NSString *)srcPath
                                  toPath:(NSString *)dstPath
                                destName:(NSString *)destName
                                 options:(int)flags
                    statusChangeInterval:(CFTimeInterval)statusChangeInterval
                                   error:(NSError**)error
{    
    const char* src = [self fileSystemRepresentationWithPath:srcPath];
    const char* dst = [self fileSystemRepresentationWithPath:dstPath];
    
    MZAsyncOperation* ret = [[MZAsyncOperation alloc] initWithManager:self];

    FSFileOperationClientContext clientContext;
    clientContext.version = 0;
    clientContext.version = 0;
    clientContext.info = ret;
    clientContext.retain = MZRetain;
    clientContext.release = MZRelease;
    clientContext.copyDescription = MZCopyDescription;

    [ret schedule];
    OSStatus status = FSPathCopyObjectAsync(
        ret.operation,
        src,
        dst,
        (CFStringRef)destName,
        flags,
        MZCopyFSPathFileOperationStatusProc,
        statusChangeInterval,
        &clientContext
    );
    if(status!=0)
    {
        if(error)
            *error = status2Error(status);
        [ret release];
        return nil;
    }
    return [ret autorelease];
}

- (MZAsyncOperation*)moveItemAsyncAtPath:(NSString *)srcPath
                                  toPath:(NSString *)dstPath
                                destName:(NSString *)destName
                                 options:(int)flags
                    statusChangeInterval:(CFTimeInterval)statusChangeInterval
                                   error:(NSError**)error
{
    const char* src = [self fileSystemRepresentationWithPath:srcPath];
    const char* dst = [self fileSystemRepresentationWithPath:dstPath];
    
    MZAsyncOperation* ret = [[MZAsyncOperation alloc] initWithManager:self];

    FSFileOperationClientContext clientContext;
    clientContext.version = 0;
    clientContext.version = 0;
    clientContext.info = ret;
    clientContext.retain = MZRetain;
    clientContext.release = MZRelease;
    clientContext.copyDescription = MZCopyDescription;

    [ret schedule];
    OSStatus status = FSPathMoveObjectAsync(
        ret.operation,
        src,
        dst,
        (CFStringRef)destName,
        flags,
        MZMoveFSPathFileOperationStatusProc,
        statusChangeInterval,
        &clientContext
    );
    if(status!=0)
    {
        if(error)
            *error = status2Error(status);
        [ret release];
        return nil;
    }
    return [ret autorelease];
}

- (void)asyncCopyOperation:(MZAsyncOperation *)operation
               currentItem:(NSString *)currentItem
                     stage:(FSFileOperationStage)stage
                     error:(NSError*)error
          statusDictionary:(NSDictionary*)statusDictionary
{
    [[self delegate] asyncCopyOperation:operation currentItem:currentItem stage:stage error:error statusDictionary:statusDictionary];
}

- (void)asyncMoveOperation:(MZAsyncOperation *)operation
               currentItem:(NSString *)currentItem
                     stage:(FSFileOperationStage)stage
                     error:(NSError*)error
          statusDictionary:(NSDictionary*)statusDictionary;
{
    [[self delegate] asyncMoveOperation:operation currentItem:currentItem stage:stage error:error statusDictionary:statusDictionary];
}

@end


@implementation NSObject (MZAsyncOperationAdditions)

- (void)asyncCopyOperation:(MZAsyncOperation *)operation
               currentItem:(NSString *)currentItem
                     stage:(FSFileOperationStage)stage
                     error:(NSError*)error
          statusDictionary:(NSDictionary*)statusDictionary
{
}

- (void)asyncMoveOperation:(MZAsyncOperation *)operation
               currentItem:(NSString *)currentItem
                     stage:(FSFileOperationStage)stage
                     error:(NSError*)error
          statusDictionary:(NSDictionary*)statusDictionary
{
}

@end