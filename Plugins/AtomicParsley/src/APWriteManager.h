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
    id<MZDataWriteDelegate> delegate;
}
@property(readonly) NSTask* task;
@property(readonly) id<MZDataWriteDelegate> delegate;

+ (id)managerWithTask:(NSTask *)task
             delegate:(id<MZDataWriteDelegate>)delegate;
- (id)initWithTask:(NSTask *)task
          delegate:(id<MZDataWriteDelegate>)delegate;

- (void)launch;

- (BOOL)isRunning;
- (void)terminate;

- (void)taskTerminated:(NSNotification *)note;
- (void)handlerGotData:(NSNotification *)note;

@end
