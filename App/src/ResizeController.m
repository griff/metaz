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

- (id)init
{
    return [super init];
}

-(void)dealloc {
    [filesBox release];
    [searchBox release];
    [tabView release];
    [splitView release];
    [super dealloc];
}

#pragma mark - as window delegate

- (NSSize)windowWillResize:(NSWindow *)window toSize:(NSSize)proposedFrameSize {
    CGFloat divider = [splitView dividerThickness];
    CGFloat minwidth = [[splitView window] frame].size.width - [splitView frame].size.width;
    minwidth += TABVIEW_WIDTH+2*divider;
    if(![splitView isSubviewCollapsed:filesBox])
        minwidth += FILESBOX_WIDTH;
    if(![splitView isSubviewCollapsed:searchBox])
        minwidth += SEARCHBOX_WIDTH;
    if(minwidth> proposedFrameSize.width)
        proposedFrameSize.width = minwidth;
    return proposedFrameSize;
}

#pragma mark - as splitView delegate

- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize {
    NSSize newSize = [sender frame].size;
    if(![sender isEqual:splitView])
    {
        [sender adjustSubviews];
        return;
    }

    /*
    [sender adjustSubviews];
    NSRect bounds = [sender bounds];
    NSLog(@"SplitView {{%f, %f},{%f,%f}}", bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);
    for ( NSView* view in [sender subviews] )
    {
        bounds = [view frame];
        NSLog(@"  Subview {{%f, %f},{%f,%f}}", bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);
    }
    return;
    */
    
    CGFloat widths[3]; 
    widths[0] = [searchBox frame].size.width;
    widths[1] = [tabView frame].size.width;
    widths[2] = [filesBox frame].size.width;
    CGFloat mins[3]; 
    mins[0] = SEARCHBOX_WIDTH;
    mins[1] = TABVIEW_WIDTH;
    mins[2] = FILESBOX_WIDTH;
    int amounts[3];
    amounts[0] = [splitView isSubviewCollapsed:searchBox] ? 0 : 1;
    amounts[1] = 1;
    amounts[2] = [splitView isSubviewCollapsed:filesBox] ? 0 : 1;

    CGFloat divider = [splitView dividerThickness];
    CGFloat minWidth = 2*divider;
    for(int i=0; i<3; i++) if(amounts[i] > 0) minWidth+=mins[i];

    if(newSize.width<minWidth)
    {
        [splitView adjustSubviews];
        return;
    }

    CGFloat oldWidth = 2*divider;
    for(int i=0; i<3; i++) if(amounts[i] > 0) oldWidth+=widths[i];
    //CGFloat amount = oldWidth - newSize.width;
    
    CGFloat w = newSize.width-2*divider;
    
    int count = 0;
    for(int i=0; i<3; i++) count+=amounts[i];
    CGFloat step = floor(w/count);
    for(int i=0; i<3; i++) {
        if(amounts[i]>0)
        {
            widths[i] = amounts[i]*step;
            if(widths[i]<mins[i])
            {
                widths[i] = mins[i];
                w -= mins[i];
                count -= amounts[i];
                amounts[i] = 0;
                if(count>0)
                    step = floor(w/count);
                i=-1;
            }
        }
    }
    for(int i=0; i<3; i++) if(amounts[i]>0) w-=widths[i];
    
    if(count==0)
        NSLog(@"Bad Count");

    if(w>3.0)
        NSLog(@"More width");

    int idx=0;
    while(w>0)
    {
        for(; idx<3 && amounts[idx]==0; idx = (idx+1) % count);
        widths[idx] += 1;
        w -= 1;
    }
    
    if(w>0)
        NSLog(@"More width");

    /*
    while(amount != 0.0)
    {
        amount = 0.0;
        for(int i=0; i<3; i++)
        {
            if(widths[i] < mins[i])
            {
                amount += mins[i]-widths[i];
                widths[i] = mins[i];
                count -= amounts[i];
                amounts[i] = 0;
            }
        }
        if(newSize.width==minWidth)
            amount=0;
        if(amount != 0.0)
        {
            if(count==0)
                NSLog(@"Bad Count");
            for(int i=0; i<3; i++) widths[i] -= amounts[i]*amount/count;
        }
    }
    */
    
    CGFloat newWidth = 2*divider;
    if(![splitView isSubviewCollapsed:searchBox]) newWidth+=widths[0];
    newWidth+=widths[1];
    if(![splitView isSubviewCollapsed:filesBox]) newWidth+=widths[2];
    if(newWidth != newSize.width)
        NSLog(@"Bad sum");
    
    NSRect rect = [searchBox frame];
    rect.origin.x = 0;
    rect.origin.y = 0;
    rect.size.width = widths[0];
    rect.size.height = newSize.height;
    [searchBox setFrame:rect];
    [searchBox setNeedsDisplay:YES];
    
    rect = [tabView frame];
    if([splitView isSubviewCollapsed:searchBox])
        rect.origin.x = divider;
    else
        rect.origin.x = widths[0] + divider;
    rect.origin.y = 0;
    rect.size.width = widths[1];
    rect.size.height = newSize.height;
    [tabView setFrame:rect];
    [tabView setNeedsDisplay:YES];

    rect = [filesBox frame];
    if([splitView isSubviewCollapsed:searchBox])
        rect.origin.x = widths[1] + 2*divider;
    else
        rect.origin.x = widths[0] + widths[1] + 2*divider;
    rect.origin.y = 0;
    rect.size.width = widths[2];
    rect.size.height = newSize.height;
    [filesBox setFrame:rect];
    [filesBox setNeedsDisplay:YES];
}

- (CGFloat)splitView:(NSSplitView *)sender constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)offset {
    if(![sender isEqual:splitView])
    {
        return 30;
    }
    if(offset==0)
        return SEARCHBOX_WIDTH;
    if(offset==1)
    {
        CGFloat ret = TABVIEW_WIDTH+[sender dividerThickness];
        if(![sender isSubviewCollapsed:searchBox])
        {
            CGFloat widthF = [searchBox frame].size.width;
            ret += widthF;
        }
        return ret;
    }
    return proposedMin;
}

- (CGFloat)splitView:(NSSplitView *)sender constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)offset {
    if(![sender isEqual:splitView])
    {
        return proposedMax-30;
    }

    CGFloat splitW = [sender frame].size.width;
    if(offset==1)
    {
        return splitW - FILESBOX_WIDTH;
    }
    if(offset==0)
    {
        CGFloat ret = splitW - (TABVIEW_WIDTH+2*[sender dividerThickness]);
        if(![sender isSubviewCollapsed:filesBox])
            ret -= [filesBox frame].size.width;
        return ret;
    }
    return proposedMax;
}

- (BOOL)splitView:(NSSplitView *)sender shouldCollapseSubview:(NSView *)subview forDoubleClickOnDividerAtIndex:(NSInteger)dividerIndex {
    if(![sender isEqual:splitView])
    {
        return YES;
    }

    CGFloat divider = [sender dividerThickness];
    if(dividerIndex==0 && [searchBox isEqual:subview])
    {
        if([sender isSubviewCollapsed:searchBox]) // Are we uncolapsing searchBox
        {
            CGFloat width = [searchBox frame].size.width;
            CGFloat widthT = [tabView frame].size.width;
            if(widthT-width < TABVIEW_WIDTH) // We need to adjust divider 1 if proposed width of tabView is to small
            {
                CGFloat widthS = TABVIEW_WIDTH+width+divider;
                CGFloat maxPr = [self splitView:sender constrainMaxCoordinate:[sender maxPossiblePositionOfDividerAtIndex:1] ofSubviewAt:1];
                if(widthS>maxPr) // If proposed position for divider 1 is larger than allowed max, hide filesBox 
                {
                    [filesBox setHidden:YES];
                    [sender adjustSubviews];
                    CGFloat widthSplit = [sender frame].size.width;
                    if(widthS > widthSplit) // If proposed width for searchBox leaves no room for min width of tabView
                        width -= (widthS-widthSplit); // Reduce proposed width so that tabView is exactly min width
                }
                else
                    [sender setPosition:widthS ofDividerAtIndex:1];
            }
            if(width<SEARCHBOX_WIDTH) // If proposed width of searchBox is smaller than min do nothing
            {
                return YES;
                /* Doesn't work
                NSRect rect = [[splitView window] frame];
                rect.size.width += SEARCHBOX_WIDTH-width;
                CGFloat widthSplit = [sender frame].size.width;
                
                [[splitView window] setFrame:rect display:YES];
                widthSplit = [sender frame].size.width;
                [sender setPosition:widthSplit ofDividerAtIndex:1];
                [sender adjustSubviews];
                width=SEARCHBOX_WIDTH;
                */
            }
            [sender setPosition:width ofDividerAtIndex:0];
            [sender adjustSubviews];
            return NO;
        }
        return YES;
    }
    else if([filesBox isEqual:subview])
    {
        if([sender isSubviewCollapsed:filesBox]) // Are we uncolapsing filesBox
        {
            CGFloat width = [filesBox frame].size.width;
            CGFloat widthT = [tabView frame].size.width;
            if(widthT-width < TABVIEW_WIDTH) // We need to adjust divider 0 if proposed width of tabView is to small
            {
                CGFloat widthSplit = [sender frame].size.width;
                CGFloat widthS = widthSplit-width-divider-TABVIEW_WIDTH;
                CGFloat minPr = [self splitView:sender constrainMinCoordinate:[sender minPossiblePositionOfDividerAtIndex:0] ofSubviewAt:0];
                if(widthS < minPr) // If proposed position for divider 0 is smaller than allowed min, hide searchBox 
                {
                    [searchBox setHidden:YES];
                    [sender adjustSubviews];
                    if(widthS < 0) // If proposed width for filesBox leaves no room for min width of tabView
                        width += widthS; // Reduce proposed width so that tabView is exactly min width
                }
                else
                    [sender setPosition:widthS ofDividerAtIndex:0];
            }
            if(width < FILESBOX_WIDTH) // If proposed width of filesBox is smaller than min do nothing
                return YES;

            [sender setPosition:width ofDividerAtIndex:1];
            [sender adjustSubviews];
            return NO;
        }
        return YES;
    }
    return NO;
}

- (BOOL)splitView:(NSSplitView *)sender canCollapseSubview:(NSView *)subview {
    return ![sender isEqual:splitView] || [searchBox isEqual:subview] || [filesBox isEqual:subview];
}

@end
