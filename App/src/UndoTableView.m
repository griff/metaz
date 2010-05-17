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

@end
