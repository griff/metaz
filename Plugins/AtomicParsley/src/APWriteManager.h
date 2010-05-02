//
//  APWriteManager.h
//  MetaZ
//
//  Created by Brian Olsen on 29/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/MetaZKit.h>
#import "APDataProvider.h"

@interface APChapterWriteTask : MZTaskOperation
{
    NSString* chaptersFile;
}
+ (id)taskWithLaunchPath:(NSString *)path filePath:(NSString*)filePath chaptersFile:(NSString *)chaptersFile;
- (id)initWithLaunchPath:(NSString *)path filePath:(NSString*)filePath chaptersFile:(NSString *)chaptersFile;

@end


@interface APWriteManager : NSOperation <MZDataController>
{
    NSTask* task;
    BOOL finished;
    NSString* pictureFile;
    NSString* chaptersFile;
    MetaEdits* edits;
    id<MZDataWriteDelegate> delegate;
    APDataProvider* provider;
    NSPipe* err;
}
@property(readonly) NSTask* task;
@property(readonly) id<MZDataWriteDelegate> delegate;
@property(readonly) MetaEdits* edits;
@property(readonly) APDataProvider* provider;
@property(getter=isFinished,assign) BOOL finished;

+ (id)managerForProvider:(APDataProvider*)provider
                    task:(NSTask *)task
                delegate:(id<MZDataWriteDelegate>)delegate
                   edits:(MetaEdits *)edits
             pictureFile:(NSString *)file
            chaptersFile:(NSString *)chapterFile;
- (id)initForProvider:(APDataProvider*)provider
                 task:(NSTask *)task
             delegate:(id<MZDataWriteDelegate>)delegate
                edits:(MetaEdits *)edits
          pictureFile:(NSString *)file
         chaptersFile:(NSString *)chapterFile;

- (void)start;

- (BOOL)isConcurrent;
- (BOOL)isExecuting;
//- (BOOL)isFinished;

- (void)cancel;

- (void)taskTerminated:(NSNotification *)note;
- (void)handlerGotData:(NSNotification *)note;

@end
