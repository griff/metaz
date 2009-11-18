//
//  PresetsController.m
//  MetaZ
//
//  Created by Brian Olsen on 26/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "PresetsWindowController.h"
#import "MZPresets.h"

@implementation PresetsWindowController

- (id)initWithController:(NSArrayController*)controller
{
    self = [super initWithWindowNibName:@"PresetsPanel"];
    if(self)
    {
        filesController = [controller retain];
        undoManager = [[NSUndoManager alloc] init];
    }
    return self;
}


- (void)dealloc
{
    [filesController removeObserver:self forKeyPath:@"selection.providedTags"];
    [presetsController removeObserver:self forKeyPath:@"selection.name"];
    [presetsController release];
    [filesController release];
    [presetsView release];
    [undoManager release];
    [super dealloc];
}

- (void)awakeFromNib
{
    NSArray* sorters = [presetsController sortDescriptors];
    if(sorters == nil || [sorters count] == 0)
    {
        NSTableColumn* column = [[presetsView tableColumns] objectAtIndex:0];
        [presetsController setSortDescriptors:[NSArray arrayWithObject:[column sortDescriptorPrototype]]];
    }
    [filesController addObserver:self
                      forKeyPath:@"selection.providedTags"
                         options:0
                         context:nil];
    [presetsController addObserver:self
                      forKeyPath:@"selection.name"
                         options:0
                         context:nil];
    [self checkSegmentEnabled];
}

@synthesize presetsController;
@synthesize filesController;
@synthesize presetsView;
@synthesize segmentedControl;

- (void)checkSegmentEnabled
{
    NSArray* tags = [filesController protectedValueForKeyPath:@"selection.providedTags"];
    id value = [presetsController protectedValueForKeyPath:@"selection.name"];

    if(!tags || tags == NSNoSelectionMarker || tags == NSMultipleValuesMarker || tags == NSNotApplicableMarker)
    {
        [segmentedControl setEnabled:NO forSegment:0];
        [segmentedControl setEnabled:NO forSegment:2];
    }
    else
    {
        [segmentedControl setEnabled:YES forSegment:0];
        if(value == NSNoSelectionMarker)
            [segmentedControl setEnabled:NO forSegment:2];
        else
            [segmentedControl setEnabled:YES forSegment:2];
    }
    
    if(value == NSNoSelectionMarker)
        [segmentedControl setEnabled:NO forSegment:1];
    else
        [segmentedControl setEnabled:YES forSegment:1];
}

#pragma mark - as observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(([keyPath isEqual:@"selection.providedTags"] && object == filesController) ||
        ([keyPath isEqual:@"selection.name"] && object == presetsController))
    {
        [self checkSegmentEnabled];
    }

}

#pragma mark - actions

- (IBAction)segmentClicked:(id)sender
{
    int clickedSegment = [sender selectedSegment];
    if(clickedSegment == 0)
        [self addPreset:sender];
    else if(clickedSegment == 1)
        [self removePreset:sender];
    else if(clickedSegment == 2)
        [self applyPreset:sender];
}

- (IBAction)applyPreset:(id)sender
{
    MZPreset* preset = [presetsController valueForKeyPath:@"selection.self"];
    if(preset)
    {
        /*
        [undoManager setActionName:NSLocalizedString(@"Apply Preset", @"Apply preset undo name")];
        NSArray* selected = [filesController selectedObjects];
        for(MetaEdits* edit in selected)
            [undoManager 
        */
        [preset applyToObject:filesController withPrefix:@"selection."];
    }
}

- (IBAction)addPreset:(id)sender
{
    NSArray* tags = [filesController protectedValueForKeyPath:@"selection.providedTags"];
    if(!tags || tags == NSNoSelectionMarker || tags == NSMultipleValuesMarker || tags == NSNotApplicableMarker)
        return;
    NSMutableDictionary* values = [NSMutableDictionary dictionaryWithCapacity:[tags count]];
    for(MZTag* tag in tags)
    {
        NSString* aKey = [@"selection." stringByAppendingString:[tag identifier]];
        NSString* changedKey = [aKey stringByAppendingString:@"Changed"];
        id changed = [filesController protectedValueForKeyPath:changedKey];
        if([changed isKindOfClass:[NSNumber class]] && [changed boolValue])
        {
            id value = [filesController valueForKeyPath:aKey];
            if(!(value == NSMultipleValuesMarker || 
                 value == NSNoSelectionMarker || 
                 value == NSNotApplicableMarker))
            {
                [values setObject:[tag convertObjectForStorage:value] forKey:[tag identifier]];
            }
        }
    }
    MZPreset* preset = [MZPreset
        presetWithName:NSLocalizedString(@"New preset", @"Default preset name") 
        values:values];
    //[presetsController setSortDescriptors:nil];
    [presetsController addObject:preset];
    //[presetsController rearrangeObjects];
    //[[MZPresets sharedPresets] addObject:preset];
    NSInteger idx = [[presetsController arrangedObjects] indexOfObject:preset];
    //NSInteger rows = [presetsView numberOfRows];
    [presetsView selectRowIndexes:[NSIndexSet indexSetWithIndex:idx] byExtendingSelection:NO];
    [presetsView editColumn:0 row:idx withEvent:nil select:YES];
}

- (IBAction)removePreset:(id)sender
{
    [presetsController remove:sender];
}

#pragma mark - as window delegate
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return undoManager;
}

@end
