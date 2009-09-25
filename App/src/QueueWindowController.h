//
//  QueueWindowController.h
//  MetaZ
//
//  Created by Brian Olsen on 14/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QueueController.h"


@interface QueueWindowController : NSWindowController <NSUserInterfaceValidations> {
    QueueController *controller;
}
@property (readonly) QueueController* controller;
@property (nonatomic, retain) IBOutlet NSToolbarItem* playBtn;
@property (nonatomic, retain) IBOutlet NSToolbarItem* pauseBtn;

- (IBAction)startStopEncoding:(id)sender;
- (IBAction)pauseResumeEncoding:(id)sender;
- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem;

@end
