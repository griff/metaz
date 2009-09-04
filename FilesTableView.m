//
//  MyTableView.m
//  MetaZ
//
//  Created by Brian Olsen on 02/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "FilesTableView.h"

@implementation FilesTableView

-(IBAction)delete:(id)sender {
    [filesController remove:sender];
}

-(IBAction)beginEnterEdit:(id)sender {
    NSInteger row = [self selectedRow];
    [self editColumn:0 row:row withEvent:nil select:YES];
}

- (BOOL)validateUserInterfaceItem:(id < NSValidatedUserInterfaceItem >)anItem {
    SEL action = [anItem action];
    SEL deleteSel = @selector(delete:);
    if(action == deleteSel)
        return [self numberOfSelectedRows] > 0;
    return [super validateUserInterfaceItem:anItem];
}

- (void)keyDown:(NSEvent *)theEvent {
    NSString* ns = [theEvent charactersIgnoringModifiers];
    NSUInteger modifierFlags = [theEvent modifierFlags]; 
    if([ns length] == 1)
    {
        unichar ch = [ns characterAtIndex:0];
        //NSLog(@"keyDown %x %x", ch, NSNewlineCharacter);
        switch(ch) {
            case NSNewlineCharacter:
                //NSLog(@"Caught NL");
            case NSCarriageReturnCharacter:
                //NSLog(@"Caught CR");
            case NSEnterCharacter:
                //NSLog(@"Caught Enter");
                if([self numberOfSelectedRows] == 1) {
                    [self beginEnterEdit:self];
                    return;
                }
                break;
            case NSBackspaceCharacter:
            case NSDeleteCharacter:
                if([self numberOfSelectedRows] > 0 && (modifierFlags & NSCommandKeyMask) == NSCommandKeyMask )
                {
                    //NSLog(@"Caught Cmd-Backspace");
                    [self delete:self];
                    return;
                }
        }
    }
    [super keyDown:theEvent];
}

@end
