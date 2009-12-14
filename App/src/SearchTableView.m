//
//  SearchTableView.m
//  MetaZ
//
//  Created by Brian Olsen on 17/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "SearchTableView.h"


@implementation SearchTableView
@synthesize searchController;

- (NSMenu *)menuForEvent:(NSEvent *)event
{
    NSPoint event_location = [event locationInWindow];
    NSPoint local_point = [self convertPointFromBase:event_location];
    NSInteger row = [self rowAtPoint:local_point];
    [self selectRow:row byExtendingSelection:NO];
    MZSearchResult* object = [[searchController arrangedObjects] objectAtIndex:row];
    if([object menu] && [self menu])
    {
        NSMenu* cp = [[[self menu] copy] autorelease];
        for(NSMenuItem* item in [cp itemArray])
            [item setRepresentedObject:self];
        //[cp addItem:[NSMenuItem separatorItem]];
        for(NSMenuItem* item in [[object menu] itemArray])
            [cp addItem:[[item copy] autorelease]];
        return cp;
    }
    if([object menu])
        return [object menu];
    return [self menu];
}

- (void)setAction:(SEL)aSelector
{
    [self setDoubleAction:aSelector];
}

@end
