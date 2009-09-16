//
//  QueueController.h
//  MetaZ
//
//  Created by Brian Olsen on 14/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MZWriteQueue.h"

@interface QueueController : NSObject {
    NSWindow* mainWindow;
    NSWindowController* controller;
    MZWriteQueue* writeQueue;
}
@property (nonatomic, retain) IBOutlet NSWindow* mainWindow;

- (IBAction)addToQueue:(id)sender;
- (IBAction)showQueue:(id)sender;
- (IBAction)startStopEncoding:(id)sender;
- (IBAction)pauseResumeEncoding:(id)sender;

@end
