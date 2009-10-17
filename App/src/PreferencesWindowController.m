//
//  PreferencesWindowController.m
//  MetaZ
//
//  Created by Brian Olsen on 27/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "PreferencesWindowController.h"

@implementation PreferencesWindowController
@synthesize pluginsButton;
@synthesize foldersButton;
@synthesize generalView;
@synthesize fileView;
@synthesize pluginsView;

- (id)init
{
    return [super initWithWindowNibName:@"PreferencesWindow"];
}

- (void)dealloc
{
    [pluginsButton release];
    [foldersButton release];
    [generalView release];
    [fileView release];
    [pluginsView release];
    [views release];
    [toolbar release];
    [super dealloc];
}

- (void)awakeFromNib
{
    views = [[NSArray alloc] initWithObjects:generalView, fileView, pluginsView, nil];
    [pluginsButton setImage:[[NSWorkspace sharedWorkspace] iconForFileType:@"mzplugin"]];
    [foldersButton setImage:[[NSWorkspace sharedWorkspace] iconForFileType:(NSString*)kUTTypeFolder]];
    toolbar = [[pluginsButton toolbar] retain];
    
    int idx = [[NSUserDefaults standardUserDefaults] integerForKey:@"selectedPreferenceItem"];
    if(idx<0 || idx>=[views count])
        idx = 0;
    
    NSString* ident = [[[toolbar items] objectAtIndex:idx] itemIdentifier];
    [toolbar setSelectedItemIdentifier:ident];
    NSView* view = [views objectAtIndex:idx];
    NSSize size = [view frame].size;
    [[self window] setContentView:view];
    [[self window] setContentSize:size];
}

- (IBAction)clearGenres:(id)sender
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"genres"];
}

- (IBAction)clearAlerts:(id)sender
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"alerts"];
}

- (IBAction)selectTabFromTag:(id)sender
{
    [[self window] setTitle:[sender label]];
    int tag = [sender tag];
    
    [[NSUserDefaults standardUserDefaults] setInteger:tag forKey:@"selectedPreferenceItem"];
    
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

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)theToolbar
{
    return [[theToolbar items] arrayByPerformingSelector:@selector(itemIdentifier)];
}

@end
