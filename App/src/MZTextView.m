//
//  MZTextView.m
//  MetaZ
//
//  Created by Brian Olsen on 07/11/12.
//  Copyright 2012 Maven-Group. All rights reserved.
//

#import "MZTextView.h"


@interface MZTextViewObserver : NSObject {
    id owner;
    id observer;
    NSString* keyPath;
}
@property(readonly) id owner;
@property(readonly) id observer;
@property(readonly) NSString* keyPath;

+ (id)observerWithOwner:(id)theOwner observer:(id)observer keyPath:(NSString *)keyPath;
- (id)initWithOwner:(id)theOwner observer:(id)observer keyPath:(NSString *)keyPath;
@end


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
    NSMutableArray* observers;
}
- (id)initWithView:(MZTextView *)theTextView controller:(id)theController; 
@end


@implementation MZTextViewObserver
@synthesize owner;
@synthesize observer;
@synthesize keyPath;

+ (id)observerWithOwner:(id)theOwner observer:(id)observer keyPath:(NSString *)keyPath;
{
    return [[[self alloc] initWithOwner:theOwner observer:observer keyPath:keyPath] autorelease];
}

- (id)initWithOwner:(id)theOwner observer:(id)anObserver keyPath:(NSString *)theKeyPath;
{
    self = [super init];
    if(self)
    {
        owner = [theOwner retain];
        observer = [anObserver retain];
        keyPath = [theKeyPath copy];
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if(![object isKindOfClass:[MZTextViewObserver class]])
        return NO;
    MZTextViewObserver* other = (MZTextViewObserver *)object;
    return owner == other.owner && observer == other.observer &&
        [keyPath isEqualToString:other.keyPath];
}

- (void)observeValueForKeyPath:(NSString *)theKeyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [observer observeValueForKeyPath:theKeyPath ofObject:owner change:change context:context];
}

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

- (BOOL)conformsToProtocol:(Protocol *)aProtocol
{
    return [editor conformsToProtocol:aProtocol];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    return [editor respondsToSelector:aSelector];
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
    observers = [[NSMutableArray alloc] init];
    return self;
}

- (void)dealloc
{
    for(MZTextViewObserver* ob in observers)
        [controller removeObserver:ob forKeyPath:ob.keyPath];
    [textView release];
    [controller release];
    [editor release];
    [observers release];
    [super dealloc];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol
{
    return [controller conformsToProtocol:aProtocol];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    return [controller respondsToSelector:aSelector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    return [controller methodSignatureForSelector:aSelector];
}

- (void)addObserver:(NSObject *)anObserver forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context
{
    MZTextViewObserver* ob = [MZTextViewObserver observerWithOwner:self observer:anObserver keyPath:keyPath];
    [controller addObserver:ob forKeyPath:keyPath options:options context:context];
    [observers addObject:ob];
}

- (void)removeObserver:(NSObject *)anObserver forKeyPath:(NSString *)keyPath
{
    MZTextViewObserver* ob = [MZTextViewObserver observerWithOwner:self observer:anObserver keyPath:keyPath];
    NSUInteger idx = [observers indexOfObject:ob];
    if(idx != NSNotFound)
    {
        ob = [observers objectAtIndex:idx];
        [controller removeObserver:ob forKeyPath:keyPath];
        [observers removeObjectAtIndex:idx];
    }
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
