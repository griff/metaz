//
//  PresetsController.h
//  MetaZ
//
//  Created by Brian Olsen on 26/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PresetsWindowController : NSWindowController
{
    NSArrayController* filesController;
    NSArrayController* presetsController;
}

- (IBAction)applyPreset:(id)sender;
- (IBAction)addPreset:(id)sender;

@end
