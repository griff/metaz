#import "DelegatedStuff.h"

#define SEARCHBOX_WIDTH 100.0
#define TABVIEW_WIDTH 363.0
#define FILESBOX_WIDTH 150.0

@implementation DelegatedStuff

-(void)awakeFromNib {
    [seasonFormatter setNilSymbol:@""];
    [episodeFormatter setNilSymbol:@""];
    [filesController addObserver:self
                      forKeyPath:@"arrangedObjects.@count"
                         options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld|NSKeyValueObservingOptionInitial
                         context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    int value = [[object valueForKeyPath:keyPath] intValue];
    if(value > 0)
        [filesSegmentControl setEnabled:YES forSegment:1];
    else
        [filesSegmentControl setEnabled:NO forSegment:1];
    
    /*
    id cnt = [change objectForKey:NSKeyValueChangeNewKey];
    NSNumber* count = cnt;
    NSArray* keys = [change allKeys];
    for(NSString* key in keys)
        NSLog(@"Wee key %@ %@", key, [change objectForKey:key]);
    if(cnt != [NSNull null])
        NSLog(@"Wee count %d", [count intValue]);
    else
        NSLog(@"Wee flom %@", value);
    */
}

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
    CGFloat amount = oldWidth - newSize.width;
    
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

- (IBAction)testyMe:(id)sender {
    NSLog(@"Finally Here");
    //[shortDescription cell
}

- (IBAction)openFile:(id)sender {
    NSArray *fileTypes = [loader extensions];
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
        [loader loadFromFiles: [oPanel filenames]];
}

@end
