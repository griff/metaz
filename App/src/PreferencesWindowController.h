//
//  PreferencesWindowController.h
//  MetaZ
//
//  Created by Brian Olsen on 27/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MZPluginController.h"

@interface PreferencesWindowController : NSWindowController {
    NSTabView* tabView;
    NSToolbarItem* pluginsButton;
}
@property (nonatomic,retain) IBOutlet NSTabView* tabView;
@property (nonatomic,retain) IBOutlet NSToolbarItem* pluginsButton;

- (id)init;

- (IBAction)selectTabFromTag:(id)sender;
- (IBAction)addPlugin:(id)sender;
- (IBAction)removePlugin:(id)sender;

- (MZPluginController *)pluginController;

@end
