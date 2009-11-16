//
//  QueueController.h
//  MetaZ
//
//  Created by Brian Olsen on 14/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MZWriteQueue.h"

@interface QueueController : NSObject <NSUserInterfaceValidations> {
    NSArrayController* filesController;
    NSWindow* mainWindow;
    NSWindowController* controller;
    MZWriteQueue* writeQueue;
    NSToolbarItem* playBtn;
    NSToolbarItem* playBtn2;
    NSInteger lastCompletedItemsCount;
    NSInteger lastQueueItemsCount;
    NSInteger targetProgress;
    NSInteger progress;
}
@property (nonatomic, retain) IBOutlet NSArrayController* filesController;
@property (nonatomic, retain) IBOutlet NSWindow* mainWindow;
@property (nonatomic, retain) IBOutlet NSToolbarItem* playBtn;
@property (nonatomic, retain) NSToolbarItem* playBtn2;
@property (readonly) NSInteger targetProgress;
@property (readonly) NSInteger progress;

- (IBAction)addToQueue:(id)sender;
- (IBAction)showQueue:(id)sender;
- (IBAction)startStopEncoding:(id)sender;

- (void)updateButtons;

@end
