//
//  PresetsController.m
//  MetaZ
//
//  Created by Brian Olsen on 26/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "PresetsWindowController.h"
#import "MZPresets.h"

@interface PresetsUndoHelper : NSObject
{
    PresetsWindowController* controller;
    MetaEdits* edit;
    BOOL observing;
}
@property (readonly) PresetsWindowController* controller;
@property (readonly) MetaEdits* edit;

+ (id)helperWithController:(PresetsWindowController *)theController edit:(MetaEdits *)theEdit;
- (id)initWithController:(PresetsWindowController *)theController edit:(MetaEdits *)theEdit;

- (void)addObservers;
- (void)removeObservers;

- (void)registerUndo;

- (void)doUndo;
- (void)doRedo;

@end


@interface PresetsWindowController ()

- (void)addPresetObject:(MZPreset*)preset;
- (void)removePresetObject:(MZPreset*)preset;

- (void)registerUndoName:(NSUndoManager *)manager;
- (void)removeHelper:(id)object;

@end


@implementation PresetsWindowController

- (id)initWithController:(NSArrayController*)controller
{
    self = [super initWithWindowNibName:@"PresetsPanel"];
    if(self)
    {
        filesController = [controller retain];
        undoManager = [[NSUndoManager alloc] init];
        undoHelpers = [[NSMutableSet alloc] init];
    }
    return self;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [filesController removeObserver:self forKeyPath:@"selection.providedTags"];
    [presetsController removeObserver:self forKeyPath:@"selection.name"];
    [presetsController release];
    [filesController release];
    [presetsView release];
    [undoManager release];
    [undoHelpers release];
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
    
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(renamedPreset:)
               name:MZPresetRenamedNotification
             object:nil];

    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(removedEdit:)
               name:MZMetaEditsDeallocating
             object:nil];
}

@synthesize presetsController;
@synthesize filesController;
@synthesize presetsView;
@synthesize segmentedControl;
@synthesize undoManager;

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

- (void)renamedPreset:(NSNotification *)note
{
    MZPreset* preset = [note object];
    NSString* oldName = [[note userInfo] objectForKey:MZPresetOldNameKey];
    [undoManager registerUndoWithTarget:preset selector:@selector(setName:) object:oldName];
    [undoManager setActionName:NSLocalizedString(@"Rename", @"Preset rename undo action")];
    [presetsController rearrangeObjects];
    [[self window] performSelectorOnMainThread:@selector(makeFirstResponder:) withObject:presetsView waitUntilDone:NO];
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
        NSArray* selected = [filesController selectedObjects];
        NSMutableSet* helpers = [NSMutableSet set];
        for(MetaEdits* edit in selected)
        {
            PresetsUndoHelper* helper = [PresetsUndoHelper helperWithController:self edit:edit];
            if([undoHelpers containsObject:helper])
            {
                helper = [undoHelpers member:helper];
                [helper removeObservers];
            }
            [helpers addObject:helper];
            [self registerUndoName:edit.undoManager];
        }

        [preset applyToObject:filesController withPrefix:@"selection."];

        for(PresetsUndoHelper* helper in helpers)
        {
            [helper registerUndo];
            [self registerUndoName:helper.edit.undoManager];
            [helper addObservers];
        }
        [undoHelpers unionSet:helpers];
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
    [self addPresetObject:preset];
    NSInteger idx = [[presetsController arrangedObjects] indexOfObject:preset];
    [presetsView selectRowIndexes:[NSIndexSet indexSetWithIndex:idx] byExtendingSelection:NO];
    [presetsView editColumn:0 row:idx withEvent:nil select:YES];
}

- (IBAction)removePreset:(id)sender
{
    MZPreset* preset = [presetsController valueForKeyPath:@"selection.self"];
    if(preset)
        [self removePresetObject:preset];
}


#pragma mark - Undo helpers

- (void)addPresetObject:(MZPreset*)preset
{
    [presetsController addObject:preset];
    [presetsController rearrangeObjects];
    if([undoManager isUndoing] || [undoManager isRedoing])
        [[self window] performSelectorOnMainThread:@selector(makeFirstResponder:) withObject:presetsView waitUntilDone:NO];
    if([undoManager isUndoing])
        [undoManager setActionName:NSLocalizedString(@"Remove Preset", @"Remove preset name")];
    else
        [undoManager setActionName:NSLocalizedString(@"Add Preset", @"Add preset name")];
    [undoManager registerUndoWithTarget:self selector:@selector(removePresetObject:) object:preset];
}

- (void)removePresetObject:(MZPreset*)preset
{
    [presetsController removeObject:preset];    
    if([undoManager isUndoing])
        [undoManager setActionName:NSLocalizedString(@"Add Preset", @"Add preset name")];
    else
        [undoManager setActionName:NSLocalizedString(@"Remove Preset", @"Remove preset name")];
    [undoManager registerUndoWithTarget:self selector:@selector(addPresetObject:) object:preset];
}

- (void)registerUndoName:(NSUndoManager *)manager
{
    [manager setActionName:NSLocalizedString(@"Apply Preset", @"Apply preset undo name")];
    [manager registerUndoWithTarget:self 
                           selector:@selector(registerUndoName:)
                             object:manager];
}

#pragma mark - undo synch notifications

- (void)removedEdit:(NSNotification *)note
{
    MetaEdits* other = [note object];
    [other.undoManager removeAllActionsWithTarget:self];
}

- (void)removeHelper:(id)object
{
    [undoHelpers removeObject:object];
}


#pragma mark - as window delegate
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return undoManager;
}

@end


@implementation PresetsUndoHelper

+ (id)helperWithController:(PresetsWindowController *)theController edit:(MetaEdits *)theEdit;
{
    return [[[self alloc] initWithController:theController edit:theEdit] autorelease];
}

- (id)initWithController:(PresetsWindowController *)theController edit:(MetaEdits *)theEdit;
{
    self = [super init];
    if(self)
    {
        controller = theController;
        edit = theEdit;
        observing = NO;
    }
    return self;
}

- (void)dealloc
{
    [controller.undoManager removeAllActionsWithTarget:self];
    [self removeObservers];
    [super dealloc];
}

- (NSUInteger)hash
{
    return [edit hash];
}

- (BOOL)isEqual:(id)anObject
{
    if(![anObject isKindOfClass:[self class]])
        return NO;
    PresetsUndoHelper* other = anObject;
    return self->edit == other->edit;
}

@synthesize controller;
@synthesize edit;

- (void)addObservers
{
    [[NSNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(madeAction:)
                   name:MZMetaEditsDeallocating
                 object:edit];
    [[NSNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(madeAction:)
                   name:NSUndoManagerDidOpenUndoGroupNotification
                 object:edit.undoManager];
    [[NSNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(madeAction:)
                   name:NSUndoManagerDidRedoChangeNotification
                 object:edit.undoManager];
    [[NSNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(madeAction:)
                   name:NSUndoManagerDidUndoChangeNotification
                 object:edit.undoManager];
    observing = YES;
}

- (void)removeObservers
{
    if(observing)
    {
        [[NSNotificationCenter defaultCenter]
                removeObserver:self
                          name:MZMetaEditsDeallocating
                        object:edit];
        [[NSNotificationCenter defaultCenter]
                removeObserver:self
                          name:NSUndoManagerDidOpenUndoGroupNotification
                        object:edit.undoManager];
        [[NSNotificationCenter defaultCenter]
                removeObserver:self
                          name:NSUndoManagerDidRedoChangeNotification
                        object:edit.undoManager];
        [[NSNotificationCenter defaultCenter]
                removeObserver:self
                          name:NSUndoManagerDidUndoChangeNotification
                        object:edit.undoManager];
        observing = NO;
    }
}

- (void)madeAction:(NSNotification *)note
{
    [controller removeHelper:self];
}

- (void)registerUndo
{
    [controller.undoManager setActionName:NSLocalizedString(@"Apply Preset", @"Apply preset undo name")];
    [controller.undoManager registerUndoWithTarget:self
                                          selector:@selector(doUndo)
                                            object:nil];
}

- (void)doUndo
{
    [self removeObservers];
    [edit.undoManager undo];
    [controller.undoManager setActionName:NSLocalizedString(@"Apply Preset", @"Apply preset undo name")];
    [controller.undoManager registerUndoWithTarget:self
                                          selector:@selector(doRedo)
                                            object:nil];
    [self addObservers];
}

- (void)doRedo
{
    [self removeObservers];
    [edit.undoManager redo];
    [controller.undoManager setActionName:NSLocalizedString(@"Apply Preset", @"Apply preset undo name")];
    [controller.undoManager registerUndoWithTarget:self
                                          selector:@selector(doUndo)
                                            object:nil];
    [self addObservers];
}

@end
