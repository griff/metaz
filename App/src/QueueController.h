//
//  QueueController.h
//  MetaZ
//
//  Created by Brian Olsen on 14/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>
#import <UKDockProgressIndicator.h>
#import "MZWriteQueue.h"

@interface QueueController : NSObject <NSUserInterfaceValidations,GrowlApplicationBridgeDelegate> {
    NSArrayController* filesController;
    NSWindow* mainWindow;
    NSWindowController* controller;
    MZWriteQueue* writeQueue;
    NSToolbarItem* playBtn;
    NSToolbarItem* playBtn2;
    NSMenuItem* menuItem;
    NSInteger lastCompletedItemsCount;
    NSInteger lastQueueItemsCount;
    NSInteger targetProgress;
    NSInteger progress;
    NSDate* startTime;
    UKDockProgressIndicator* dockIndicator;
    NSProgressIndicator* progressBar;
    NSView* mainView;
    NSView* pendingLabel;
    CGFloat progressResizeHeight;
}
@property (nonatomic, retain) IBOutlet NSArrayController* filesController;
@property (nonatomic, retain) IBOutlet NSWindow* mainWindow;
@property (nonatomic, retain) IBOutlet NSToolbarItem* playBtn;
@property (nonatomic, retain) NSToolbarItem* playBtn2;
@property (nonatomic, retain) IBOutlet NSMenuItem* menuItem;
@property (nonatomic, retain) IBOutlet NSProgressIndicator* progressBar;
@property (nonatomic, retain) IBOutlet NSView* mainView;
@property (nonatomic, retain) IBOutlet NSView* pendingLabel;
@property (readonly) NSInteger targetProgress;
@property (readonly) NSInteger progress;

- (IBAction)addToQueue:(id)sender;
- (IBAction)showQueue:(id)sender;
- (IBAction)startStopEncoding:(id)sender;

- (void)updateUI;

@end
