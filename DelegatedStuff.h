#import <Cocoa/Cocoa.h>
#import "MZMetaLoader.h"

@interface DelegatedStuff : NSObject {
    IBOutlet NSWindow* window;
    IBOutlet NSBox *filesBox;
    IBOutlet NSBox *searchBox;
    IBOutlet NSTabView *tabView;
    IBOutlet NSSplitView *splitView;
    IBOutlet MZMetaLoader *loader;
    IBOutlet NSArrayController* filesController;
    IBOutlet NSNumberFormatter* episodeFormatter;
    IBOutlet NSNumberFormatter* seasonFormatter;
    IBOutlet NSSegmentedControl* filesSegmentControl;
}
- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize;
- (NSSize)windowWillResize:(NSWindow *)window toSize:(NSSize)proposedFrameSize;
- (CGFloat)splitView:(NSSplitView *)sender constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)offset;
- (CGFloat)splitView:(NSSplitView *)sender constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)offset;
- (BOOL)splitView:(NSSplitView *)splitView shouldCollapseSubview:(NSView *)subview forDoubleClickOnDividerAtIndex:(NSInteger)dividerIndex;
- (BOOL)splitView:(NSSplitView *)sender canCollapseSubview:(NSView *)subview;
- (IBAction)showAdvancedTab:(id)sender;
- (IBAction)showChapterTab:(id)sender;
- (IBAction)showInfoTab:(id)sender;
- (IBAction)showSortTab:(id)sender;
- (IBAction)showVideoTab:(id)sender;
- (IBAction)segmentClicked:(id)sender;
- (IBAction)selectNextFile:(id)sender;
- (IBAction)selectPreviousFile:(id)sender;
- (IBAction)showPreferences:(id)sender;
//- (IBAction)testyMe:(id)sender;
- (IBAction)revertChanges:(id)sender;
- (IBAction)openFile:(id)sender;
- (void)openPanelDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode  contextInfo:(void  *)contextInfo;

@end
