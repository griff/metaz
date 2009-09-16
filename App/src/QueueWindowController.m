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
        controller = [owner retain];
    }
    return self;
}

-(void)dealloc
{
    [controller release];
    [super dealloc];
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
    NSView* sv = [aTabView superview];
    NSView* box = [sv superview];
    NSCollectionView* colview = (NSCollectionView*)[box superview];
    NSRect tabRect = [aTabView frame];
    NSRect svRect = [sv frame];
    NSRect boxRect = [box frame];
    if([[tabViewItem identifier] isEqual:@"pending"])
    {
        boxRect.size.height = 43;
        svRect.size.height = 41;
        tabRect.size.height = 41;
    } else
    {
        boxRect.size.height = 53;
        svRect.size.height = 51;
        tabRect.size.height = 51;
    }
    [box setFrameSize:boxRect.size];
    [sv setFrame:svRect];
    [aTabView setFrame:tabRect];
    [box setNeedsDisplay:YES];
    [sv setNeedsDisplay:YES];
    [aTabView setNeedsDisplay:YES];
    [colview setNeedsDisplay:YES];
    NSRect tabRect2 = [aTabView frame];
    NSRect svRect2 = [sv frame];
    NSRect rect2 = [box frame];
}

@end
