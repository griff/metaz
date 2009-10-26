//
//  PresetsController.m
//  MetaZ
//
//  Created by Brian Olsen on 26/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "PresetsWindowController.h"
#import "MZPresets.h"

@implementation PresetsWindowController

- (IBAction)applyPreset:(id)sender
{
    MZPreset* preset = [presetsController valueForKeyPath:@"selection.self"];
    if(preset)
        [preset applyToObject:filesController withPrefix:@"selection."];
}

- (IBAction)addPreset:(id)sender
{
}

@end
