//
//  QueueWindowController.h
//  MetaZ
//
//  Created by Brian Olsen on 14/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QueueController.h"


@interface QueueWindowController : NSWindowController {
    QueueController *controller;
}
@property (readonly) QueueController* controller;

- (IBAction)startStopEncoding:(id)sender;
- (IBAction)pauseResumeEncoding:(id)sender;
- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem;

@end
