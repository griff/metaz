#import "ResizeController.h"

#define SEARCHBOX_WIDTH 100.0
#define TABVIEW_WIDTH 363.0
#define FILESBOX_WIDTH 150.0

@implementation ResizeController
@synthesize filesBox;
@synthesize searchBox;
@synthesize tabView;
@synthesize splitView;

#pragma mark - initialization

-(void)dealloc {
    [filesBox release];
    [searchBox release];
    [tabView release];
    [splitView release];
    [super dealloc];
}

#pragma mark - as window delegate

- (NSSize)windowWillResize:(NSWindow *)window toSize:(NSSize)proposedFrameSize {
    
    const CGFloat minSplitViewWidth = FILESBOX_WIDTH + TABVIEW_WIDTH + SEARCHBOX_WIDTH + 2 * [splitView dividerThickness];
    const CGFloat margin = CGRectGetMinX([splitView frame]);
    
    proposedFrameSize.width = MAX(proposedFrameSize.width, minSplitViewWidth + margin * 2.0);

    return proposedFrameSize;
}

#pragma mark - as splitView delegate

- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize {
    
    const CGFloat mins[] = { FILESBOX_WIDTH, TABVIEW_WIDTH, SEARCHBOX_WIDTH };
    const CGFloat splitViewHeight = [sender bounds].size.height;
    const CGFloat dividerThickness = [sender dividerThickness];
    
    // Invoke default OS behavior
    [sender adjustSubviews];
    
    CGFloat offset = 0;
    for(NSUInteger i = 0; splitView == sender && i < 3; ++i)
    {
        NSView* subview = [[sender subviews] objectAtIndex:i];
        NSRect viewFrame = [subview frame];
        
        if (viewFrame.size.width < mins[i])
        {
            [subview setFrameSize: NSMakeSize(mins[i], splitViewHeight)];
            viewFrame = [subview frame];
        }
        
        [subview setFrameOrigin:NSMakePoint(offset, viewFrame.origin.y)];
        [subview setNeedsDisplay: YES];

        offset += viewFrame.size.width + dividerThickness;
    }
}

- (CGFloat)splitView:(NSSplitView *)sender constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)offset {
    
    if (sender != splitView)
    {
        proposedMin = 30;
    }
    else
    {
        const CGFloat mins[] = { FILESBOX_WIDTH, TABVIEW_WIDTH, SEARCHBOX_WIDTH };
        proposedMin = CGRectGetMinX([[[sender subviews] objectAtIndex: offset] frame]) + mins[offset];
    }

    return proposedMin;
}

- (CGFloat)splitView:(NSSplitView *)sender constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)offset {
    
    if (sender != splitView)
    {
        proposedMax -= 30;
    }
    else
    {
        const CGFloat mins[] = { FILESBOX_WIDTH, TABVIEW_WIDTH, SEARCHBOX_WIDTH };
        NSView *thisView = [[sender subviews] objectAtIndex:offset];
        NSView *nextView = [[sender subviews] objectAtIndex:offset + 1];
        proposedMax = CGRectGetMaxX([thisView frame]) + [nextView frame].size.width - mins[offset+1];
    }

    return proposedMax;
}

- (BOOL)splitView:(NSSplitView *)sender shouldCollapseSubview:(NSView *)subview forDoubleClickOnDividerAtIndex:(NSInteger)dividerIndex {
    
    if(sender == splitView && tabView == subview)
    {
        return NO;
    }
    
    return YES;
}

- (BOOL)splitView:(NSSplitView *)sender canCollapseSubview:(NSView *)subview {

    return sender != splitView || filesBox == subview || searchBox == subview;
}

@end
