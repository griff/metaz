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

@interface APWriteManager : NSObject <MZDataWriteController> {
    NSTask* task;
    BOOL terminated;
    NSString* pictureFile;
    NSString* chaptersFile;
    MetaEdits* edits;
    id<MZDataWriteDelegate> delegate;
    APDataProvider* provider;
}
@property(readonly) NSTask* task;
@property(readonly) id<MZDataWriteDelegate> delegate;
@property(readonly) MetaEdits* edits;
@property(readonly) APDataProvider* provider;

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

- (void)launch;

- (BOOL)isRunning;
- (void)terminate;

- (void)taskTerminated:(NSNotification *)note;
- (void)handlerGotData:(NSNotification *)note;

@end
