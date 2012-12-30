#import <Cocoa/Cocoa.h>
#import "MZMetaLoader.h"

@interface ResizeController : NSObject {
    NSBox *filesBox;
    NSView* searchBox;
    NSTabView *tabView;
    NSSplitView *splitView;
}
@property (nonatomic, retain) IBOutlet NSBox *filesBox;
@property (nonatomic, retain) IBOutlet NSView* searchBox;
@property (nonatomic, retain) IBOutlet NSTabView *tabView;
@property (nonatomic, retain) IBOutlet NSSplitView *splitView;

#pragma mark - as window delegate

- (NSSize)windowWillResize:(NSWindow *)window toSize:(NSSize)proposedFrameSize;

#pragma mark - as splitView delegate
- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize;
- (CGFloat)splitView:(NSSplitView *)sender constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)offset;
- (CGFloat)splitView:(NSSplitView *)sender constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)offset;
- (BOOL)splitView:(NSSplitView *)splitView shouldCollapseSubview:(NSView *)subview forDoubleClickOnDividerAtIndex:(NSInteger)dividerIndex;
- (BOOL)splitView:(NSSplitView *)sender canCollapseSubview:(NSView *)subview;

@end
