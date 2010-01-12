//
//  NSFileManager+MZAsync.h
//  MetaZ
//
//  Created by Brian Olsen on 07/01/10.
//  Copyright 2010 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MZAsyncOperation : NSObject
{
    NSFileManager* fileManager;
    FSFileOperationRef operation;
    CFRunLoopRef runLoop;
    CFStringRef runLoopMode;
}
@property (readonly) NSFileManager* fileManager;
@property (readonly) FSFileOperationRef operation;

- (id)initWithManager:(NSFileManager *)fileManager;

- (OSStatus)schedule;
- (OSStatus)unschedule;
- (OSStatus)cancel;

@end


@interface NSFileManager (MZAsync)

- (MZAsyncOperation*)copyItemAsyncAtPath:(NSString *)srcPath
                                  toPath:(NSString *)dstPath
                                destName:(NSString *)destName
                                 options:(int)flags
                    statusChangeInterval:(CFTimeInterval)statusChangeInterval
                                   error:(NSError**)error;

- (MZAsyncOperation*)moveItemAsyncAtPath:(NSString *)srcPath
                                  toPath:(NSString *)dstPath
                                destName:(NSString *)destName
                                 options:(int)flags
                    statusChangeInterval:(CFTimeInterval)statusChangeInterval
                                   error:(NSError**)error;

- (void)asyncCopyOperation:(MZAsyncOperation *)operation
               currentItem:(NSString *)currentItem
                     stage:(FSFileOperationStage)stage
                     error:(NSError*)error
          statusDictionary:(NSDictionary*)statusDictionary;

- (void)asyncMoveOperation:(MZAsyncOperation *)operation
               currentItem:(NSString *)currentItem
                     stage:(FSFileOperationStage)stage
                     error:(NSError*)error
          statusDictionary:(NSDictionary*)statusDictionary;

@end


@interface NSObject (MZAsyncOperationAdditions)

- (void)asyncCopyOperation:(MZAsyncOperation *)operation
               currentItem:(NSString *)currentItem
                     stage:(FSFileOperationStage)stage
                     error:(NSError*)error
          statusDictionary:(NSDictionary*)statusDictionary;

- (void)asyncMoveOperation:(MZAsyncOperation *)operation
               currentItem:(NSString *)currentItem
                     stage:(FSFileOperationStage)stage
                     error:(NSError*)error
          statusDictionary:(NSDictionary*)statusDictionary;

@end