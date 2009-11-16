//
//  QueueWindowController.m
//  MetaZ
//
//  Created by Brian Olsen on 14/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "QueueWindowController.h"
#import "MGCollectionView.h"

@implementation QueueWindowController
@synthesize controller;
@synthesize collectionView;
@synthesize itemsLabel;
@synthesize clearBtn;

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
    [collectionView release];
    [itemsLabel release];
    [clearBtn release];
    [super dealloc];
}

- (void)awakeFromNib
{
    [[itemsLabel cell] setBackgroundStyle:NSBackgroundStyleRaised];
    [[clearBtn cell] setBackgroundStyle:NSBackgroundStyleRaised];
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

- (BOOL)validateUserInterfaceItem:(id < NSValidatedUserInterfaceItem >)anItem
{
    return [controller validateUserInterfaceItem:anItem];
}

- (IBAction)startStopEncoding:(id)sender
{
    [controller startStopEncoding:sender];
}

- (void)tabView:(NSTabView *)aTabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    NSView* box = [[aTabView superview] superview];
    NSRect frame = [box frame];

    CGFloat newHeight;
    NSTabViewItem * item = [aTabView selectedTabViewItem];
    if([[item identifier] isEqual:@"action"])
        newHeight = 53;
    else
        newHeight = 43;
    if(frame.size.height != newHeight)
    {
        frame.size.height = newHeight;
        [box setFrame:frame];
        [collectionView setNeedsLayout:YES];
    }
}


@end
