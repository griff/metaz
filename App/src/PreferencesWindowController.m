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
@synthesize generalView;
@synthesize pluginsView;

- (id)init
{
    return [super initWithWindowNibName:@"PreferencesWindow"];
}

- (void)dealloc
{
    [tabView release];
    [pluginsButton release];
    [generalView release];
    [pluginsView release];
    [views release];
    [super dealloc];
}

- (void)awakeFromNib
{
    [pluginsButton setImage:[[NSWorkspace sharedWorkspace] iconForFileType:@"mzplugin"]];
    NSToolbar* toolbar = [pluginsButton toolbar];
    NSString* ident = [[[toolbar items] objectAtIndex:0] itemIdentifier];
    [toolbar setSelectedItemIdentifier:ident];
    views = [[NSArray alloc] initWithObjects:generalView, pluginsView, nil];
    NSSize size = [generalView frame].size;
    [[self window] setContentView:generalView];
    [[self window] setContentSize:size];
}

- (IBAction)selectTabFromTag:(id)sender;
{
    [[self window] setTitle:[sender label]];
    int tag = [sender tag];
    NSView* view = [views objectAtIndex:tag];
    NSSize size = [view frame].size;
    NSSize contentSize = [[[self window] contentView] frame].size;
    NSRect frame = [[self window] frame];
    
    frame.origin.y += frame.size.height;
    frame.size.height = frame.size.height - contentSize.height + size.height;
    frame.size.width = frame.size.width - contentSize.width + size.width;
    frame.origin.y -= frame.size.height;
    [[self window] setContentView:view];
    [[self window] setFrame:frame display:YES animate:YES];
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
