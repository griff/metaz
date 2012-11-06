//
//  QueueController.h
//  MetaZ
//
//  Created by Brian Olsen on 14/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <UKDockProgressIndicator.h>
#import "MZWriteQueue.h"
#import "MZViewAnimation.h"

@interface QueueController : NSObject <NSUserInterfaceValidations> {
    NSArrayController* filesController;
    NSWindow* mainWindow;
    NSWindowController* controller;
    MZWriteQueue* writeQueue;
    NSInteger lastCompletedItemsCount;
    NSInteger lastQueueItemsCount;
    NSInteger targetProgress;
    NSInteger progress;
    UKDockProgressIndicator* dockIndicator;
    NSProgressIndicator* progressBar;
    NSView* mainView;
    NSView* pendingLabel;
    CGFloat progressResizeHeight;
    MZViewAnimation* animation;
    NSRect mainRect;
    NSRect pendingRect;
    NSRect progressRect;
    BOOL progressShowing;
}
@property (nonatomic, retain) IBOutlet NSArrayController* filesController;
@property (nonatomic, retain) IBOutlet NSWindow* mainWindow;
@property (nonatomic, retain) IBOutlet NSProgressIndicator* progressBar;
@property (nonatomic, retain) IBOutlet NSView* mainView;
@property (nonatomic, retain) IBOutlet NSView* pendingLabel;
@property (readonly) NSInteger targetProgress;
@property (readonly) NSInteger progress;

- (IBAction)writeSelected:(id)sender;
- (IBAction)writeAll:(id)sender;
- (IBAction)addToQueue:(id)sender;
- (IBAction)addAllToQueue:(id)sender;
- (IBAction)showQueue:(id)sender;
- (IBAction)startEncoding:(id)sender;
- (IBAction)stopEncoding:(id)sender;
- (IBAction)startStopEncoding:(id)sender;

- (void)updateUI;

@end
