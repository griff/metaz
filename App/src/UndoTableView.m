//
//  UndoTableView.m
//  MetaZ
//
//  Created by Brian Olsen on 11/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "UndoTableView.h"

@implementation UndoTableView

- (void)dealloc
{
    [editCancelHack release];
    [super dealloc];
}

- (NSMenu *)menuForEvent:(NSEvent *)event
{
    NSPoint event_location = [event locationInWindow];
    NSPoint local_point = [self convertPointFromBase:event_location];
    NSInteger row = [self rowAtPoint:local_point];
    [self selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
    
    NSMenu* menu = nil;

    id ds = [self dataSource];
    if(ds)
    {
        if([ds respondsToSelector:@selector(tableView:menuForRow:)])
            menu = [ds tableView:self menuForRow:row];
    }
    if(!menu)
    {
        NSDictionary* dict = [self infoForBinding:@"content"];
        if(dict)
        {
            id observed = [dict objectForKey:NSObservedObjectKey];
            NSString* keyPath = [dict objectForKey:NSObservedKeyPathKey];
            NSArray* content = [observed valueForKeyPath:keyPath];
            id object = [content objectAtIndex:row];
            if(object && [object respondsToSelector:@selector(menu)])
                menu = [object menu];
        }
    }
    
    if(menu && [self menu])
    {
        NSMenu* cp = [[[self menu] copy] autorelease];
        for(NSMenuItem* item in [cp itemArray])
            [item setRepresentedObject:self];
        for(NSMenuItem* item in [menu itemArray])
            [cp addItem:[[item copy] autorelease]];
        return cp;
    }
    if(menu)
        return menu;
    return [self menu];
}

-(IBAction)beginEnterEdit:(id)sender
{
    NSInteger row = [self selectedRow];
    NSArray* columns = [self tableColumns];
    int i = 0;
    for(NSTableColumn* column in columns)
    {
        if([column isEditable])
        {
            [self editColumn:i row:row withEvent:nil select:YES];
            return;
        }
        i++;
    }
}

- (void)keyDown:(NSEvent *)theEvent
{
    NSString* ns = [theEvent charactersIgnoringModifiers];
    if([ns length] == 1)
    {
        unichar ch = [ns characterAtIndex:0];
        //MZLoggerDebug(@"keyDown %x %x", ch, NSNewlineCharacter);
        switch(ch) {
            case NSNewlineCharacter:
                //MZLoggerDebug(@"Caught NL");
            case NSCarriageReturnCharacter:
                //MZLoggerDebug(@"Caught CR");
            case NSEnterCharacter:
                //MZLoggerDebug(@"Caught Enter");
                if([self numberOfSelectedRows] == 1) {
                    [self beginEnterEdit:self];
                    return;
                }
                break;
        }
    }
    [super keyDown:theEvent];
}

- (void)setAction:(SEL)aSelector
{
    [self setDoubleAction:aSelector];
}


#pragma mark - as text view delegate
- (BOOL)textView:(NSTextView *)aTextView doCommandBySelector:(SEL)aSelector
{
    if(aSelector == @selector(insertNewlineIgnoringFieldEditor:))
    {
        [aTextView insertNewline:self];
        return YES;
    }
    if(aSelector == @selector(cancelOperation:))
    {
        if(editCancelHack)
            [aTextView setString:editCancelHack];
        [aTextView insertNewline:self];
        return YES;
    }
    return NO;
}

- (BOOL)textShouldBeginEditing:(NSText *)text
{
    [editCancelHack release];
    editCancelHack = [[text string] copy];
    return [super textShouldBeginEditing:text];
}

- (void)textDidEndEditing:(NSNotification *)aNotification
{
    [editCancelHack release];
    editCancelHack = nil;
    [super textDidEndEditing:aNotification];
}

@end
