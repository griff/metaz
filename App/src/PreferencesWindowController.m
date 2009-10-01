//
//  PreferencesWindowController.m
//  MetaZ
//
//  Created by Brian Olsen on 27/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "PreferencesWindowController.h"

@implementation PreferencesWindowController
@synthesize tabView;
@synthesize pluginsButton;

- (id)init
{
    return [super initWithWindowNibName:@"PreferencesWindow"];
}

- (void)dealloc
{
    [tabView release];
    [pluginsButton release];
    [super dealloc];
}

- (void)awakeFromNib
{
    [pluginsButton setImage:[[NSWorkspace sharedWorkspace] iconForFileType:@"mzplugin"]];
    NSToolbar* toolbar = [pluginsButton toolbar];
    NSString* ident = [[[toolbar items] objectAtIndex:0] itemIdentifier];
    [toolbar setSelectedItemIdentifier:ident];
}

- (IBAction)selectTabFromTag:(id)sender;
{
    int tag = [sender tag];
    [tabView selectTabViewItemAtIndex:tag];
}

- (IBAction)addPlugin:(id)sender
{
}

- (IBAction)removePlugin:(id)sender
{
}

- (MZPluginController *)pluginController
{
    return [MZPluginController sharedInstance];
}

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar
{
    return [[toolbar items] arrayByPerformingSelector:@selector(itemIdentifier)];
}

@end
