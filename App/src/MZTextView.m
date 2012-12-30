//
//  MZTextView.m
//  MetaZ
//
//  Created by Brian Olsen on 07/11/12.
//  Copyright 2012 Maven-Group. All rights reserved.
//

#import "MZTextView.h"


/*!
 * The proxy for talking to the editor
 */
@interface MZTextViewEditorProxy : NSProxy {
    MZTextView* textView;
    id editor;
}
@property(retain) id editor;
- (id)initWithView:(MZTextView *)theTextView;
@end


/*!
 * The proxy for talking to the controller
 */
@interface MZTextViewBindProxy : NSProxy {
    MZTextView* textView;
    id controller;
    MZTextViewEditorProxy* editor;
}
- (id)initWithView:(MZTextView *)theTextView controller:(id)theController; 
@end


@implementation MZTextViewEditorProxy
@synthesize editor;

- (id)initWithView:(MZTextView *)theTextView
{
    textView = [theTextView retain];
    return self;
}

- (void)dealloc
{
    [editor release];
    [textView release];
    [super dealloc];
}
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    return [editor methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    [anInvocation setTarget:editor];
    [anInvocation invoke];
}

- (BOOL)commitEditing
{
    BOOL ret = [editor commitEditing];
    [[textView window] makeFirstResponder:textView];
    return ret;
}

-(void)commitEditingWithDelegate:(id)delegate didCommitSelector:(SEL)didCommitSelector contextInfo:(void *)contextInfo
{
    [editor commitEditingWithDelegate:delegate didCommitSelector:didCommitSelector contextInfo:contextInfo];
    [[textView window] makeFirstResponder:textView];
}

- (void)discardEditing
{
    [editor discardEditing];
    [[textView window] makeFirstResponder:textView];
}

@end


@implementation MZTextViewBindProxy

- (id)initWithView:(MZTextView *)theTextView controller:(id)theController
{
    textView = [theTextView retain];
    controller = [theController retain];
    editor = [[MZTextViewEditorProxy alloc] initWithView:textView];
    return self;
}

- (void)dealloc
{
    [textView release];
    [controller release];
    [editor release];
    [super dealloc];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    return [controller methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    [anInvocation setTarget:controller];
    [anInvocation invoke];
}

- (BOOL)commitEditing
{
    return [controller commitEditing];
}

-(void)commitEditingWithDelegate:(id)delegate didCommitSelector:(SEL)didCommitSelector contextInfo:(void *)contextInfo
{
    [controller commitEditingWithDelegate:delegate didCommitSelector:didCommitSelector contextInfo:contextInfo];
}

- (void)discardEditing
{
    [controller discardEditing];
}

- (void)objectDidBeginEditing:(id)theEditor
{
    editor.editor = theEditor;
    [controller objectDidBeginEditing:editor];
}

- (void)objectDidEndEditing:(id)theEditor
{
    [controller objectDidEndEditing:editor];
    if(editor.editor!=theEditor)
    {
        [NSException raise:@"NSArgumentException" format:@"Bad editor"];
    }
}

@end


@implementation MZTextView

- (void)bind:(NSString *)binding toObject:(id)observableController
        withKeyPath:(NSString *)keyPath
            options:(NSDictionary *)options
{
    id proxy = [observableController retain];
    if([observableController isKindOfClass:[NSController class]])
    {
        [proxy release];
        proxy = [[MZTextViewBindProxy alloc]
            initWithView:self controller:observableController];
    }
    [super bind:binding toObject:proxy withKeyPath:keyPath options:options];
    [proxy release];
}

- (void)insertNewline:(id)sender
{
    [super insertNewline:sender];
    if([self isFieldEditor])
        [[self window] makeFirstResponder:self];
}

@end
