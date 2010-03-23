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
#import "ImageWindowController.h"
#import "PreferencesWindowController.h"
#import "PresetsWindowController.h"
#import "SearchProfile.h"
#import "ChapterEditor.h"

@interface AppController : NSObject <NSUserInterfaceValidations,MZPluginControllerDelegate> {
    NSWindow* window;
    NSTabView *tabView;
    NSNumberFormatter* episodeFormatter;
    NSNumberFormatter* seasonFormatter;
    NSDateFormatter* dateFormatter;
    NSDateFormatter* purchaseDateFormatter;
    NSSegmentedControl* filesSegmentControl;
    NSArrayController* filesController;
    ResizeController* resizeController;
    FilesUndoController* undoController;
    NSTextView* shortDescription;
    NSTextView* longDescription;
    NSUndoManager* undoManager;
    NSImageView* imageView;
    ImageWindowController* imageEditController;
    PreferencesWindowController* prefController;
    PresetsWindowController* presetsController;
    NSProgressIndicator* searchIndicator;
    NSArrayController* searchController;
    NSSearchField* searchField;
    NSInteger remainingInShortDescription;
    SearchProfile* activeProfile;
    NSInteger searches;
    ChapterEditor* chapterEditor;
    NSProgressIndicator* loadingIndicator;
    NSInteger loadings;
}
@property (nonatomic, retain) IBOutlet NSWindow* window;
@property (nonatomic, retain) IBOutlet NSTabView *tabView;
@property (nonatomic, retain) IBOutlet NSNumberFormatter* episodeFormatter;
@property (nonatomic, retain) IBOutlet NSNumberFormatter* seasonFormatter;
@property (nonatomic, retain) IBOutlet NSDateFormatter* dateFormatter;
@property (nonatomic, retain) IBOutlet NSDateFormatter* purchaseDateFormatter;
@property (nonatomic, retain) IBOutlet NSSegmentedControl* filesSegmentControl;
@property (nonatomic, retain) IBOutlet NSArrayController* filesController;
@property (nonatomic, retain) IBOutlet ResizeController* resizeController;
@property (nonatomic, retain) IBOutlet FilesUndoController* undoController;
@property (nonatomic, retain) IBOutlet NSTextView* shortDescription;
@property (nonatomic, retain) IBOutlet NSTextView* longDescription;
@property (nonatomic, retain) IBOutlet NSImageView* imageView;
@property (nonatomic, retain) IBOutlet NSProgressIndicator* searchIndicator;
@property (nonatomic, retain) IBOutlet NSArrayController* searchController;
@property (nonatomic, retain) IBOutlet NSSearchField* searchField;
@property (nonatomic, retain) IBOutlet ChapterEditor* chapterEditor;
@property (nonatomic, retain) IBOutlet NSProgressIndicator* loadingIndicator;
@property (readonly) NSInteger remainingInShortDescription;

+ (void)initialize;

#pragma mark - actions

- (IBAction)showAdvancedTab:(id)sender;
- (IBAction)showChapterTab:(id)sender;
- (IBAction)showInfoTab:(id)sender;
- (IBAction)showSortTab:(id)sender;
- (IBAction)showVideoTab:(id)sender;
- (IBAction)segmentClicked:(id)sender;
- (IBAction)selectNextFile:(id)sender;
- (IBAction)selectPreviousFile:(id)sender;
- (IBAction)selectNextResult:(id)sender;
- (IBAction)selectPreviousResult:(id)sender;
- (IBAction)showPreferences:(id)sender;
- (IBAction)revertChanges:(id)sender;
- (IBAction)showImageEditor:(id)sender;
- (IBAction)startSearch:(id)sender;
- (IBAction)searchForImages:(id)sender;
- (IBAction)openDocument:(id)sender;
- (IBAction)showPresets:(id)sender;
- (IBAction)applySearchEntry:(id)sender;
- (IBAction)showReleaseNotes:(id)sender;
- (IBAction)showHomepage:(id)sender;
- (IBAction)viewLog:(id)sender;
- (IBAction)sendFeedback:(id)sender;

//- (void)openPanelDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode  contextInfo:(void  *)contextInfo;

#pragma mark - as window delegate
- (NSSize)windowWillResize:(NSWindow *)window toSize:(NSSize)proposedFrameSize;
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window;

#pragma mark - as application delegate

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename;
- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames;
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender;

@end
