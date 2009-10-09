//
//  APWriteManager.h
//  MetaZ
//
//  Created by Brian Olsen on 29/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/MetaZKit.h>

@interface APWriteManager : NSObject <MZDataWriteController> {
    NSTask* task;
    BOOL terminated;
    NSString* pictureFile;
    MetaEdits* edits;
    id<MZDataWriteDelegate> delegate;
    id<MZDataProvider> provider;
}
@property(readonly) NSTask* task;
@property(readonly) id<MZDataWriteDelegate> delegate;
@property(readonly) MetaEdits* edits;
@property(readonly) id<MZDataProvider> provider;

+ (id)managerForProvider:(id<MZDataProvider>)provider
                    task:(NSTask *)task
                delegate:(id<MZDataWriteDelegate>)delegate
                   edits:(MetaEdits *)edits
             pictureFile:(NSString *)file;
- (id)initForProvider:(id<MZDataProvider>)provider
                 task:(NSTask *)task
             delegate:(id<MZDataWriteDelegate>)delegate
                edits:(MetaEdits *)edits
          pictureFile:(NSString *)file;

- (void)launch;

- (BOOL)isRunning;
- (void)terminate;

- (void)taskTerminated:(NSNotification *)note;
- (void)handlerGotData:(NSNotification *)note;

@end
