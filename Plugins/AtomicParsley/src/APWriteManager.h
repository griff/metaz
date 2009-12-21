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

@interface APWriteManager : NSOperation <MZDataWriteController> {
    NSTask* task;
    BOOL isFinished;
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
@property(assign) BOOL isFinished;

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
- (BOOL)isFinished;

- (void)cancel;

- (void)taskTerminated:(NSNotification *)note;
- (void)handlerGotData:(NSNotification *)note;

@end
