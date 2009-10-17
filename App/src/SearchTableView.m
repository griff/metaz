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
    return [object menu];
}

@end
