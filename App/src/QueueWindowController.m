//
//  QueueWindowController.m
//  MetaZ
//
//  Created by Brian Olsen on 14/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "QueueWindowController.h"


@implementation QueueWindowController
@synthesize controller;

- (id)initWithWindowNibName:(NSString *)windowNibName owner:(QueueController *)owner
{
    self = [super initWithWindowNibName:windowNibName owner:self];
    if(self)
    {
        controller = owner;
    }
    return self;
}

-(void)dealloc
{
    //[controller release];
    [super dealloc];
}

- (NSToolbarItem *)playBtn
{
    return [controller playBtn2];
}

- (void)setPlayBtn:(NSToolbarItem *)newBtn
{
    [controller setPlayBtn2:newBtn];
    [controller updateButtons];
}

- (NSToolbarItem *)pauseBtn
{
    return [controller pauseBtn2];
}

- (void)setPauseBtn:(NSToolbarItem *)newBtn
{
    [controller setPauseBtn2:newBtn];
    [controller updateButtons];
}

- (BOOL)validateUserInterfaceItem:(id < NSValidatedUserInterfaceItem >)anItem
{
    return [controller validateUserInterfaceItem:anItem];
}

- (IBAction)startStopEncoding:(id)sender
{
    [controller startStopEncoding:sender];
}

- (IBAction)pauseResumeEncoding:(id)sender
{
    [controller pauseResumeEncoding:sender];
}

- (void)tabView:(NSTabView *)aTabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
}

@end
