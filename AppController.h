//
//  AppController.h
//  MetaZ
//
//  Created by Brian Olsen on 06/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MZMetaLoader.h"
#import "FilesUndoController.h"
#import "ResizeController.h"

@interface AppController : NSObject {
    NSWindow* window;
    NSTabView *tabView;
    NSNumberFormatter* episodeFormatter;
    NSNumberFormatter* seasonFormatter;
    NSSegmentedControl* filesSegmentControl;
    NSArrayController* filesController;
    ResizeController* resizeController;
    FilesUndoController* undoController;
    NSTextView* shortDescription;
    NSTextView* longDescription;
    NSUndoManager* undoManager;
}
@property (nonatomic, retain) IBOutlet NSWindow* window;
@property (nonatomic, retain) IBOutlet NSTabView *tabView;
@property (nonatomic, retain) IBOutlet NSNumberFormatter* episodeFormatter;
@property (nonatomic, retain) IBOutlet NSNumberFormatter* seasonFormatter;
@property (nonatomic, retain) IBOutlet NSSegmentedControl* filesSegmentControl;
@property (nonatomic, retain) IBOutlet NSArrayController* filesController;
@property (nonatomic, retain) IBOutlet ResizeController* resizeController;
@property (nonatomic, retain) IBOutlet FilesUndoController* undoController;
@property (nonatomic, retain) IBOutlet NSTextView* shortDescription;
@property (nonatomic, retain) IBOutlet NSTextView* longDescription;

#pragma mark - actions
- (IBAction)showAdvancedTab:(id)sender;
- (IBAction)showChapterTab:(id)sender;
- (IBAction)showInfoTab:(id)sender;
- (IBAction)showSortTab:(id)sender;
- (IBAction)showVideoTab:(id)sender;
- (IBAction)segmentClicked:(id)sender;
- (IBAction)selectNextFile:(id)sender;
- (IBAction)selectPreviousFile:(id)sender;
- (IBAction)showPreferences:(id)sender;
- (IBAction)revertChanges:(id)sender;
- (IBAction)openFile:(id)sender;
- (void)openPanelDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode  contextInfo:(void  *)contextInfo;

#pragma mark - as window delegate
- (NSSize)windowWillResize:(NSWindow *)window toSize:(NSSize)proposedFrameSize;
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window;


@end
