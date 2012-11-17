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

- (id)init {
    if ((self = [super init]))
    {
        // Read once at init time... changing this at runtime would likely be disastrous.
        searchBoxFirst = [[NSUserDefaults standardUserDefaults] boolForKey: @"searchBoxFirst"];
    }
    return self;
}

-(void)dealloc {
    [filesBox release];
    [searchBox release];
    [tabView release];
    [splitView release];
    [super dealloc];
}

- (NSBox*)leftSubview {
    return searchBoxFirst ? searchBox : filesBox;
}

- (NSTabView*)middleSubview {
    return tabView;
}

- (NSBox*)rightSubview {
    return searchBoxFirst ? filesBox : searchBox;
}

- (CGFloat)leftSubviewWidth {
    return searchBoxFirst ? SEARCHBOX_WIDTH : FILESBOX_WIDTH;
}

- (CGFloat)middleSubviewWidth {
    return TABVIEW_WIDTH;
}

- (CGFloat)rightSubviewWidth {
    return searchBoxFirst ? FILESBOX_WIDTH : SEARCHBOX_WIDTH;
}

- (void)awakeFromNib
{    
    NSArray* correctOrder = [NSArray arrayWithObjects: [self leftSubview], [self middleSubview], [self rightSubview], nil];
    if (![correctOrder isEqualToArray: [splitView subviews]])
    {
        // remove them...
        [splitView setSubviews: [NSArray array]];

        // swap frames
        CGRect temp = [filesBox frame];
        [filesBox setFrame: [searchBox frame]];
        [searchBox setFrame: temp];
        
        // put them back right
        [splitView setSubviews: correctOrder];
    }
}

#pragma mark - as window delegate

- (NSSize)windowWillResize:(NSWindow *)window toSize:(NSSize)proposedFrameSize {
    
    const CGFloat minSplitViewWidth = [self leftSubviewWidth] + [self middleSubviewWidth] + [self rightSubviewWidth] + 2 * [splitView dividerThickness];
    const CGFloat margin = CGRectGetMinX([splitView frame]);
    
    proposedFrameSize.width = MAX(proposedFrameSize.width, minSplitViewWidth + margin * 2.0);

    return proposedFrameSize;
}

#pragma mark - as splitView delegate

- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize {
    
    const CGFloat mins[] = { [self leftSubviewWidth], [self middleSubviewWidth], [self rightSubviewWidth] };
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
        const CGFloat mins[] = { [self leftSubviewWidth], [self middleSubviewWidth], [self rightSubviewWidth] };
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
        const CGFloat mins[] = { [self leftSubviewWidth], [self middleSubviewWidth], [self rightSubviewWidth] };
        NSView *thisView = [[sender subviews] objectAtIndex:offset];
        NSView *nextView = [[sender subviews] objectAtIndex:offset + 1];
        proposedMax = CGRectGetMaxX([thisView frame]) + [nextView frame].size.width - mins[offset+1];
    }

    return proposedMax;
}

- (BOOL)splitView:(NSSplitView *)sender shouldCollapseSubview:(NSView *)subview forDoubleClickOnDividerAtIndex:(NSInteger)dividerIndex {
    
    if(sender == splitView && [self middleSubview] == subview)
    {
        return NO;
    }
    
    return YES;
}

- (BOOL)splitView:(NSSplitView *)sender canCollapseSubview:(NSView *)subview {

    return sender != splitView || [self leftSubview] == subview || [self rightSubview] == subview;
}

@end
