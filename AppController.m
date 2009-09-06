//
//  AppController.m
//  MetaZ
//
//  Created by Brian Olsen on 06/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "AppController.h"


@implementation AppController
@synthesize window;
@synthesize tabView;
@synthesize episodeFormatter;
@synthesize seasonFormatter;
@synthesize filesSegmentControl;
@synthesize filesController;
@synthesize undoController;
@synthesize resizeController;
@synthesize shortDescription;
@synthesize longDescription;

#pragma mark - initialization

-(void)awakeFromNib {
    undoManager = [[NSUndoManager alloc] init];
    [seasonFormatter setNilSymbol:@""];
    [episodeFormatter setNilSymbol:@""];
    [filesController addObserver:self
                      forKeyPath:@"arrangedObjects.@count"
                         options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld|NSKeyValueObservingOptionInitial
                         context:nil];
}

-(void)dealloc {
    [filesController removeObserver:self forKeyPath:@"arrangedObjects.@count"];
    [window release];
    [tabView release];
    [episodeFormatter release];
    [seasonFormatter release];
    [filesSegmentControl release];
    [filesController release];
    [undoController release];
    [resizeController release];
    [shortDescription release];
    [longDescription release];
    [undoManager release];
    [super dealloc];
}

#pragma mark - as observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    int value = [[object valueForKeyPath:keyPath] intValue];
    if(value > 0)
        [filesSegmentControl setEnabled:YES forSegment:1];
    else
        [filesSegmentControl setEnabled:NO forSegment:1];
}

#pragma mark - actions

- (IBAction)showAdvancedTab:(id)sender {
    [tabView selectTabViewItemWithIdentifier:@"advanced"];    
}

- (IBAction)showChapterTab:(id)sender {
    [tabView selectTabViewItemWithIdentifier:@"chapters"];    
}

- (IBAction)showInfoTab:(id)sender {
    [tabView selectTabViewItemWithIdentifier:@"info"];
}

- (IBAction)showSortTab:(id)sender {
    [tabView selectTabViewItemWithIdentifier:@"sorting"];
}

- (IBAction)showVideoTab:(id)sender {
    [tabView selectTabViewItemWithIdentifier:@"video"];    
}

- (IBAction)segmentClicked:(id)sender {
    int clickedSegment = [sender selectedSegment];
    int clickedSegmentTag = [[sender cell] tagForSegment:clickedSegment];

    if(clickedSegmentTag == 0)
        [self openFile:sender];
    else
        [filesController remove:sender];
}

NSResponder* findResponder(NSWindow* window) {
    NSResponder* oldResponder =  [window firstResponder];
    if([oldResponder isKindOfClass:[NSTextView class]] && [window fieldEditor:NO forObject:nil] != nil)
    {
        NSResponder* delegate = [oldResponder delegate];
        if([delegate isKindOfClass:[NSTextField class]])
            oldResponder = delegate;
    }
    return oldResponder;
}

NSDictionary* findBinding(NSWindow* window) {
    NSResponder* oldResponder = findResponder(window);
    NSDictionary* dict = [oldResponder infoForBinding:NSValueBinding];
    if(dict == nil)
        dict = [oldResponder infoForBinding:NSDataBinding];
    return dict;
}

- (BOOL)validateUserInterfaceItem:(id < NSValidatedUserInterfaceItem >)anItem {
    SEL action = [anItem action];
    if(action == @selector(selectNextFile:))
        return [filesController canSelectNext];
    if(action == @selector(selectPreviousFile:))
        return [filesController canSelectPrevious];
    if(action == @selector(revertChanges:))
    {
        return [[filesController selectedObjects] count] >= 1 &&
            findBinding(window) != nil;
    }
    return YES;
}

- (IBAction)selectNextFile:(id)sender {
    NSResponder* oldResponder = findResponder(window);
    if([filesController commitEditing])
    {
        NSResponder* currentResponder =  findResponder(window);
        if(oldResponder != currentResponder)
            [window makeFirstResponder:oldResponder];
    }
    [filesController selectNext:sender];
}

- (IBAction)selectPreviousFile:(id)sender {
    NSResponder* oldResponder = findResponder(window);
    if([filesController commitEditing])
    {
        NSResponder* currentResponder =  findResponder(window);
        if(oldResponder != currentResponder)
            [window makeFirstResponder:oldResponder];
    }
    [filesController selectPrevious:sender];
}

- (IBAction)revertChanges:(id)sender {
    NSDictionary* dict = findBinding(window);
    if(dict == nil)
    {
        NSLog(@"Could not find binding for revert.");
        return;
    }
    id observed = [dict objectForKey:NSObservedObjectKey];
    NSString* keyPath = [dict objectForKey:NSObservedKeyPathKey];
    [observed setValue:[NSNumber numberWithBool:NO] forKeyPath:[keyPath stringByAppendingString:@"Changed"]];
}

- (IBAction)showPreferences:(id)sender {

}

- (IBAction)openFile:(id)sender {
    NSArray *fileTypes = [[MZMetaLoader sharedLoader] extensions];
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
    [oPanel setAllowsMultipleSelection:YES];
    [oPanel setCanChooseFiles:YES];
    [oPanel setCanChooseDirectories:NO];
    [oPanel beginSheetForDirectory: nil
                              file: nil
                             types: fileTypes
                    modalForWindow: window
                     modalDelegate: self
                    didEndSelector: @selector(openPanelDidEnd:returnCode:contextInfo:) 
                       contextInfo: nil];
}

- (void)openPanelDidEnd:(NSOpenPanel *)oPanel returnCode:(int)returnCode  contextInfo:(void  *)contextInfo {
    if (returnCode == NSOKButton)
        [[MZMetaLoader sharedLoader] loadFromFiles: [oPanel filenames]];
}

#pragma mark - as window delegate

- (NSSize)windowWillResize:(NSWindow *)aWindow toSize:(NSSize)proposedFrameSize {
    return [resizeController windowWillResize:aWindow toSize:proposedFrameSize];
}

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)aWindow {
    NSResponder* responder = [aWindow firstResponder];
    if(responder == shortDescription || responder == longDescription)
    {
        NSUndoManager * man = [undoController undoManager];
        if(man != nil)
            return man;
    }
    return undoManager;
}


@end
