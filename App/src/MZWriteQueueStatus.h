//
//  MZWriteQueueStatus.h
//  MetaZ
//
//  Created by Brian Olsen on 29/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/MetaZKit.h>

@interface MZWriteQueueStatus : NSObject <MZDataWriteDelegate> {
    MetaEdits* edits;
    int percent;
    int writing;
    BOOL completed;
    BOOL removeOnCancel;
    id<MZDataWriteController> controller;
}
@property(readonly) MetaEdits* edits;
@property(readonly) int percent;
@property(readonly) int writing;
@property(readonly) BOOL completed;
@property(readonly) id<MZDataWriteController> controller;

+ (id)statusWithEdits:(MetaEdits *)edits;
- (id)initWithEdits:(MetaEdits *)edits;

- (void)startWriting;
- (void)stopWriting;
- (void)stopWritingAndRemove;

- (void)writeCanceled;
- (void)writeFinished;
- (void)writeFinishedPercent:(int)percent;

@end
