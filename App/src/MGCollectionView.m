//
//  MGCollectionView.m
//  MetaZ
//
//  Created by Brian Olsen on 16/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "MGCollectionView.h"

#define ASSERT(expr) NSAssert(expr, @"Assertion failed");

static const float DRAG_START_DISTANCE = 10;
static const float DRAG_IMAGE_ALPHA = 0.5;
static NSString * const DRAG_ITEM_TYPE = @"MGCollectionViewDragType";

typedef enum
{
    DragTargetType_None,
    DragTargetType_Top,
    DragTargetType_Bottom,
} DragTargetType;

@interface MGCollectionView (Private)

// Override NSView
- (void)moveDown: (id)sender;
- (void)moveUp: (id)sender;
- (BOOL)isFlipped;
- (void)keyDown: (NSEvent *)event;
- (void)deleteBackward: (id)sender;
- (void)deleteForward: (id)sender;
- (NSDragOperation)draggingEntered: (id<NSDraggingInfo>)sender;
- (void)draggingExited: (id<NSDraggingInfo>)sender;
- (BOOL)prepareForDragOperation: (id<NSDraggingInfo>)sender;
- (BOOL)performDragOperation: (id<NSDraggingInfo>)sender;
- (NSDragOperation)draggingUpdated: (id<NSDraggingInfo>)sender;
- (BOOL)wantsPeriodicDraggingUpdates;
- (NSDragOperation)draggingSourceOperationMaskForLocal: (BOOL)isLocal;
- (void)resizeWithOldSuperviewSize: (NSSize)oldBoundsSize;

// Internal methods
- (void)setNeedsLayout: (BOOL)flag;
- (void)performLayout;
- (void)startDrag: (NSEvent *)event
         withItem: (MGCollectionViewItem *)item;
- (NSImage *)dragImageForIndexes:(NSIndexSet *)indexes
                     dragPoint: (NSPoint *)dragPoint;
- (void)itemClicked: (MGCollectionViewItem *)item
              event: (NSEvent *)event;
- (void)setAllItemsSelected: (BOOL)selected;
- (void)growSelectionToItem: (MGCollectionViewItem *)item;
- (void)moveSelection: (BOOL)moveUp
          byExtending: (BOOL)byExtending;
- (void)scrollToItem: (MGCollectionViewItem *)item;
- (void)maintainNonEmptySelection: (NSUInteger)index;
- (void)removeItemsAtIndexes:(NSIndexSet *)indexes;
- (int)indexFromDragTarget: (NSView *)targetView
              draggingInfo: (id<NSDraggingInfo>)draggingInfo;
- (void)setDragTarget: (NSView *)targetView
         draggingInfo: (id<NSDraggingInfo>)draggingInfo;
- (void)setIndex: (int)index
    isDragTarget: (BOOL)isDragTarget;
- (id<MGCollectionViewTarget>)target;
- (int)dragTargetIndex;
- (void)maximizeViewWidth: (id)sender;
- (void)onKeyWindowChanged:(NSNotification *)notification;
- (void)onKeyWindowUpdated:(NSNotification *)notification;
- (void)testSelectionChanged:(NSIndexSet *)oldSelection;
- (NSArray *)filePathsForIndexes:(NSIndexSet *)indexes;

@end

@interface MGCollectionViewItem (Private)

// Override NSView
- (NSMenu *)menuForEvent:(NSEvent *)event;
- (NSView *)hitTest: (NSPoint)point;
- (void)mouseDown: (NSEvent *)event;
- (void)mouseUp: (NSEvent *)event;
- (void)mouseDragged: (NSEvent *)event;
- (BOOL)acceptsFirstResponder;

// Internal methods
- (void)setIsSelected: (BOOL)flag;
- (BOOL)isSelected;
- (MGCollectionView *)collectionView;
- (BOOL)isLeftClickEvent: (NSEvent *)event;
- (void)setDragTargetType: (DragTargetType)type;
- (DragTargetType)dragTargetType;
- (void)updateHighlightState;
- (void)setHighlight: (BOOL)isHighlighted
        forTextField: (NSTextField *)textField;
- (BOOL)shouldDrawSecondaryHighlight;

@end


static float
PointDistance(NSPoint start,
              NSPoint end)
{
    float deltaX = end.x - start.x;
    float deltaY = end.y - start.y;
    return sqrt(deltaX * deltaX + deltaY * deltaY);
}

@implementation MGCollectionView

- (id)initWithFrame: (NSRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        items = [[NSMutableArray alloc] init];
    }
    return self;
}

/*
- (MuhMaItem *)itemPrototype
{
    NSLog(@"Bad call");
}
*/

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [items release];
    items = nil;
    [super dealloc];
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow
{
    NSWindow * window = [self window];
    if(window != nil)
    {
        [[NSNotificationCenter defaultCenter]
                removeObserver:self
                          name:NSWindowDidBecomeKeyNotification
                        object:window];
        [[NSNotificationCenter defaultCenter]
                removeObserver:self
                          name:NSWindowDidResignKeyNotification
                        object:window];
                        /*
        [[NSNotificationCenter defaultCenter]
                removeObserver:self
                          name:NSWindowDidUpdateNotification
                        object:window];
                        */
    }
}

- (void)viewDidMoveToWindow
{
    NSWindow * window = [self window];
    if(window != nil)
    {
        [[NSNotificationCenter defaultCenter]
                addObserver:self
                   selector:@selector(onKeyWindowChanged:)
                       name:NSWindowDidBecomeKeyNotification
                     object:window];
        [[NSNotificationCenter defaultCenter]
                addObserver:self
                   selector:@selector(onKeyWindowChanged:)
                       name:NSWindowDidResignKeyNotification
                     object:window];
                     /*
        [[NSNotificationCenter defaultCenter]
                addObserver:self
                   selector:@selector(onKeyWindowUpdated:)
                       name:NSWindowDidUpdateNotification
                     object:window];
                     */
    }    
}

- (void)awakeFromNib
{
    NSAssert(!self.target || [self.target conformsToProtocol: @protocol(MGCollectionViewTarget)], @"Bad target");
/*
   [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(onKeyWindowChanged:)
             name:NSWindowDidBecomeKeyNotification
           object:[self window]];
   [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(onKeyWindowChanged:)
             name:NSWindowDidResignKeyNotification
           object:[self window]];
*/
    [[[self enclosingScrollView] contentView] setCopiesOnScroll:NO];

    [self registerForDraggedTypes:
        [NSArray arrayWithObjects:NSFilenamesPboardType, DRAG_ITEM_TYPE, nil]];

    [self maximizeViewWidth:nil];
}


- (void)drawRect: (NSRect)rect
{
    /*
     * XXX: This is a hack to work around autohide scrollbars not working
     * correctly. When removing an item causes the vertical scrollbar to
     * be hidden our items don't automatically resize to fit the new width.
     *
     * Until that bug is fixed this hack disables the "needsLayout" optimization
     * and forces a layout on every dray. The layout code is pretty fast so this
     * isn't very expensive.
     */
    needsLayout = YES;

    if (needsLayout) {
        [self performLayout];
        [self maintainNonEmptySelection:0];
    }
    [super drawRect:rect];

    [[NSColor colorWithCalibratedRed:214.0/255.0
                               green:221.0/255.0
                                blue:229.0/255.0
                               alpha:1.0] set];
    NSRectFill([self bounds]);
}


- (void)addItem:(MGCollectionViewItem *)item  atIndex:(NSUInteger)index
{
    ASSERT(item);
    ASSERT(index >= 0);
    [items insertObject:item atIndex:index];
    [item setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin];
    [self addSubview:item];
    [self setNeedsLayout:YES];
}

- (void)moveItem:(MGCollectionViewItem *)item toIndex:(NSUInteger)index
{
    ASSERT(item);
    ASSERT(index >= 0);
    [item retain]; // Make sure item stays alive
    [items removeObject:item];
    [items insertObject:item atIndex:index];
    [item release];
    [self setNeedsLayout:YES];
}

- (void)removeObject:(MGCollectionViewItem *)item
{
    ASSERT(item);
    NSUInteger index = [items indexOfObject:item];
    if(index == NSNotFound)
        return;
    [self removeItemAtIndex:index];
}

- (void)removeItemAtIndex: (NSUInteger)index
{
    [self removeItemsAtIndexes: [NSIndexSet indexSetWithIndex:index]];
    [self maintainNonEmptySelection:index];
}

- (void)removeAllItems
{
    [items removeAllObjects];
    [self setNeedsLayout:YES];
    [self setNeedsDisplay:YES];
}


- (int)numberOfItems
{
    return [items count];
}


- (NSIndexSet *)selectionIndexes
{
    NSMutableIndexSet *selectionIndexes = [[NSMutableIndexSet alloc] init];
    NSUInteger count = [items count];
    NSUInteger i;
    for (i = 0; i < count; i++) {
        MGCollectionViewItem *item = [items objectAtIndex:i];
        if ([item isSelected]) {
            [selectionIndexes addIndex:i];
        }
    }
    return [selectionIndexes autorelease];
}

- (void)selectIndexes:(NSIndexSet *)indexes byExtendingSelection:(BOOL)extend
{
    NSIndexSet* oldSelection = [self selectionIndexes];
    if(!extend)
        [self setAllItemsSelected:NO];
    for(MGCollectionViewItem* item in [items objectsAtIndexes:indexes])
        [item setIsSelected:YES];
    [self testSelectionChanged:oldSelection];
}

- (void)selectAll: (id)sender
{
    NSIndexSet *oldSelection = [self selectionIndexes];
    [self setAllItemsSelected:YES];
    [self testSelectionChanged:oldSelection];
}

- (void)deselectAll:(id)sender
{
    NSIndexSet *oldSelection = [self selectionIndexes];
    [self setAllItemsSelected:NO];
    [self testSelectionChanged:oldSelection];
}

@end // MGCollectionView


@implementation MGCollectionView (Private)


- (void)setNeedsLayout: (BOOL)flag
{
    needsLayout = flag;
}


- (void)performLayout
{
    // Calculate the total height.
    float myHeight = 0;
    NSEnumerator *e = [items objectEnumerator];
    MGCollectionViewItem *item;
    while ((item = [e nextObject])) {
        myHeight += [item frame].size.height;
    }

    // Resize the collection view to fit.
    NSRect myFrame = [self frame];
    [self setFrameSize:NSMakeSize(myFrame.size.width, myHeight)];
    if (myFrame.size.height != myHeight) {
        [self setNeedsDisplay:YES];
    }

    // Layout all the items.
    float yPos = 0;
    e = [items objectEnumerator];
    while ((item = [e nextObject])) {
        NSRect oldItemFrame = [item frame];
        NSRect newItemFrame;
        newItemFrame.origin.y = yPos;
        newItemFrame.origin.x = 0;
        newItemFrame.size.width = myFrame.size.width;
        newItemFrame.size.height = oldItemFrame.size.height;
        [item setFrame:newItemFrame];

        yPos += newItemFrame.size.height;
        if (!NSEqualRects(newItemFrame, oldItemFrame)) {
            [item setNeedsDisplay:YES];
        }
    }

    [self setNeedsLayout:NO];
}


- (BOOL)isFlipped
{
    return YES;
}


- (void)startDrag: (NSEvent *)event
         withItem: (MGCollectionViewItem *)item
{
    // If the dragged item is selected then drag all selected items too.
    NSIndexSet *dragIndexes = nil;
    if ([item isSelected]) {
        dragIndexes = [self selectionIndexes];
    } else {
        dragIndexes = [NSIndexSet indexSetWithIndex:[items indexOfObject:item]];
    }

    // Write data to the paste board.
    NSPasteboard *pboard = [NSPasteboard pasteboardWithName:NSDragPboard];
    [pboard declareTypes:[NSArray arrayWithObjects:DRAG_ITEM_TYPE,
                                                   NSFilenamesPboardType,
                                                   nil]
                   owner:self];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dragIndexes];
    [pboard setPropertyList:data
                    forType:DRAG_ITEM_TYPE];
    [pboard setPropertyList:[self filePathsForIndexes:dragIndexes]
                    forType:NSFilenamesPboardType];

    // Generate the drag image from the dragged items.
    NSPoint dragPos;
    NSImage *dragImage = [self dragImageForIndexes:dragIndexes dragPoint:&dragPos];

    // Start the drag.
    [self dragImage:dragImage
                 at:dragPos
             offset:NSZeroSize
              event:event
         pasteboard:pboard
             source:self
          slideBack:YES];
}


- (NSImage *)dragImageForIndexes: (NSIndexSet *)indexes
                     dragPoint: (NSPoint *)dragPoint
{
    // Make an image as big as the visible rect.
    NSRect dragRect = [self convertRect:[self visibleRect]
                               fromView:[self superview]];
    NSImage *dragImage =
       [[[NSImage alloc] initWithSize:dragRect.size] autorelease];

    /*
    NSEnumerator *e = [indexes objectEnumerator];
    NSNumber *indexNumber;
    while ((indexNumber = [e nextObject])) {
        MGCollectionViewItem *item =
            [items objectAtIndex:[indexNumber intValue]];
    */
    for(MGCollectionViewItem *item in [items objectsAtIndexes:indexes])
    {
        NSRect itemRect = [item visibleRect];
        if (NSEqualRects(itemRect, NSZeroRect)) {
            continue;
        }

        // Get an image of the dragged view without the selection.
        BOOL oldSelectedValue = [item isSelected];
        [item setIsSelected:NO];
        NSData *itemAsPDF = [item dataWithPDFInsideRect:itemRect];
        [item setIsSelected:oldSelectedValue];
        NSImage *itemImage = [[NSImage alloc] initWithData:itemAsPDF];

        // Convert from our flipped axis into the image's non-flipped axis.
        NSPoint pos = [item frame].origin;
        pos.y = dragRect.origin.y + dragRect.size.height - pos.y;
        pos.y -= itemRect.size.height;

        // Drag the view's image into the drag image.
        [dragImage lockFocus];
        [itemImage drawAtPoint:pos
                      fromRect:NSZeroRect
                     operation:NSCompositeSourceOver
                      fraction:DRAG_IMAGE_ALPHA];
        [dragImage unlockFocus];

        [itemImage release];
    }

    ASSERT(dragPoint);
    *dragPoint = NSMakePoint(dragRect.origin.x,
                             dragRect.origin.y + dragRect.size.height);

    return dragImage;
}


- (void)itemClicked: (MGCollectionViewItem *)item
              event: (NSEvent *)event
{
    NSIndexSet *oldSelection = [self selectionIndexes];

    if (([event modifierFlags] & NSCommandKeyMask) != 0) {
        [item setIsSelected:![item isSelected]];
    } else if (([event modifierFlags] & NSShiftKeyMask) != 0) {
        [self growSelectionToItem:item];
    } else {
        [self setAllItemsSelected:NO];
        [item setIsSelected:YES];
        if ([event clickCount] == 2) {
            [[self target]
                performDoubleClickActionForIndex:[items indexOfObject:item]];
        }
    }
    [self scrollToItem:item];

    [self testSelectionChanged:oldSelection];
}


- (void)setAllItemsSelected:(BOOL)selected
{
    NSEnumerator *e = [items objectEnumerator];
    MGCollectionViewItem *item;
    while ((item = [e nextObject])) {
        [item setIsSelected:selected];
    }
}


- (void)growSelectionToItem: (MGCollectionViewItem *)item
{
    NSIndexSet *oldSelection = [self selectionIndexes];

    NSUInteger itemIndex = [items indexOfObject:item];
    NSUInteger startIndex = [oldSelection firstIndex];
    NSUInteger endIndex = [oldSelection lastIndex];

    if (itemIndex < startIndex) {
        startIndex = itemIndex;
    } else if (itemIndex > endIndex) {
        endIndex = itemIndex;
    }

    NSUInteger i;
    for (i = startIndex; i <= endIndex; i++) {
        [[items objectAtIndex:i] setIsSelected:YES];
    }

    [self testSelectionChanged:oldSelection];
}


- (void)moveDown: (id)sender
{
    BOOL shift = ([[NSApp currentEvent] modifierFlags] & NSShiftKeyMask) != 0;
    [self moveSelection:NO byExtending:shift];
}


- (void)moveUp: (id)sender
{
    BOOL shift = ([[NSApp currentEvent] modifierFlags] & NSShiftKeyMask) != 0;
    [self moveSelection:YES byExtending:shift];
}


- (void)moveSelection: (BOOL)moveUp
          byExtending: (BOOL)byExtending
{
    if ([items count] == 0) {
        return;
    }
    NSIndexSet *oldSelection = [self selectionIndexes];

    NSUInteger index = NSNotFound;
    if (moveUp) {
        NSUInteger firstIndex = [oldSelection firstIndex];
        firstIndex--;
        if (firstIndex >= 0) {
            index = firstIndex;
        }
    } else {
        NSUInteger lastIndex = [oldSelection lastIndex];
        lastIndex++;
        if (lastIndex < [items count]) {
            index = lastIndex;
        }
    }

    if (index != NSNotFound) {
        if (!byExtending) {
            [self setAllItemsSelected:NO];
        }
        MGCollectionViewItem *item = [items objectAtIndex:index];
        [item setIsSelected:YES];
        [self scrollToItem:item];
    }

    [self testSelectionChanged:oldSelection];
}


- (void)scrollToItem: (MGCollectionViewItem *)item
{
    NSRect itemFrame = [item frame];
    NSPoint top, bottom;
    bottom.y = NSMaxY(itemFrame);
    top.y = NSMinY(itemFrame);
    top.x = 0;
    bottom.x = 0;

    NSRect visibleRect = [self visibleRect];
    BOOL bottomVisible = NSPointInRect(bottom, visibleRect);
    BOOL topVisible = NSPointInRect(top, visibleRect);
    if (!topVisible || !bottomVisible) {
        NSPoint scrollPos;
        if (!bottomVisible) {
            scrollPos.y = bottom.y - visibleRect.size.height;
        } else {
            scrollPos.y = top.y;
        }
        scrollPos.x = 0;

        NSClipView *clipView = [[self enclosingScrollView] contentView];
        [clipView scrollToPoint:[clipView constrainScrollPoint:scrollPos]];
        [[self enclosingScrollView] reflectScrolledClipView:clipView];
    }
}


- (void)maintainNonEmptySelection: (NSUInteger)index
{
    NSIndexSet *oldSelection = [self selectionIndexes];
    if ([items count] > 0 && [oldSelection count] == 0) {
        NSUInteger selectionIndex = index;
        if (selectionIndex < 0) {
            selectionIndex = 0;
        } else if (selectionIndex >= [items count]) {
            selectionIndex = [items count] - 1;
        }
        [[items objectAtIndex:selectionIndex] setIsSelected:YES];

        [self testSelectionChanged:oldSelection];
    }
}


- (void)keyDown: (NSEvent *)event
{
    unichar u = [[event charactersIgnoringModifiers] characterAtIndex: 0];

    if (u == NSDeleteCharacter ||
        u == NSDeleteFunctionKey) {
        // Forward or backward delete.
        [self interpretKeyEvents:[NSArray arrayWithObject:event]];
    } else if (u == NSEnterCharacter ||
               u == NSCarriageReturnCharacter) {
        NSIndexSet *indexes = [self selectionIndexes];
        if ([indexes count] > 0) {
            [[self target] performDoubleClickActionForIndex:
                [indexes firstIndex]];
        }
    } else {
        [super keyDown:event];
    }
}


- (void)deleteBackward: (id)sender
{
    NSIndexSet *indexes = [self selectionIndexes];
    if ([indexes count] > 0 &&
            [[self target] shouldRemoveItemsAtIndexes:indexes]) {
        [self removeItemsAtIndexes:indexes];
        [self maintainNonEmptySelection:[indexes firstIndex] - 1];
        [[self window] makeFirstResponder:self];
    }
}


- (void)deleteForward: (id)sender
{
    NSIndexSet *indexes = [self selectionIndexes];
    if ([indexes count] > 0 &&
            [[self target] shouldRemoveItemsAtIndexes:indexes]) {
        [self removeItemsAtIndexes:indexes];
        [self maintainNonEmptySelection:[indexes firstIndex]];
        [[self window] makeFirstResponder:self];
    }
}


- (void)removeItemsAtIndexes: (NSIndexSet *)indexes
{
    if ([indexes count] == 0) {
        return;
    }
   
    NSArray* to_remove = [items objectsAtIndexes:indexes];
    for(MGCollectionViewItem *item in to_remove)
        [item removeFromSuperview];
        
    [items removeObjectsAtIndexes:indexes];

    /*
     * Need to force the layout to change right away so that scrolling and
     * selection code will work.
     */
    [self performLayout];
}


- (NSDragOperation)draggingEntered: (id<NSDraggingInfo>)sender
{
    return [self draggingUpdated:sender];
}


- (void)draggingExited: (id<NSDraggingInfo>)sender
{
    [self setDragTarget:nil draggingInfo:sender];
}


- (BOOL)prepareForDragOperation: (id<NSDraggingInfo>)sender
{
    BOOL acceptDrop = NO;
    NSArray *dragTypes = [[sender draggingPasteboard] types];

    if ([dragTypes containsObject:DRAG_ITEM_TYPE]) {
        acceptDrop = YES;
    } else if ([dragTypes containsObject:NSFilenamesPboardType]) {
        NSArray *filePaths = [[sender draggingPasteboard]
            propertyListForType:NSFilenamesPboardType];
        if(self.target)
            acceptDrop = [[self target] dragOperationForFiles:filePaths] !=
                    NSDragOperationNone;
    }

    if (!acceptDrop) {
        [self setDragTarget:nil draggingInfo:sender];
    }
    return acceptDrop;
}


- (BOOL)performDragOperation: (id<NSDraggingInfo>)sender
{
    int destIndex = [self dragTargetIndex];
    ASSERT(destIndex != NSNotFound);
    [self setDragTarget:nil draggingInfo:sender];

    NSArray *dragTypes = [[sender draggingPasteboard] types];
    if ([dragTypes containsObject:DRAG_ITEM_TYPE]) {
        NSIndexSet* indexes = [NSKeyedUnarchiver unarchiveObjectWithData: [[sender draggingPasteboard] 
                                    dataForType:DRAG_ITEM_TYPE]];
        /*
        NSArray *indexes = [[sender draggingPasteboard]
                propertyListForType:DRAG_ITEM_TYPE];
        */
        [[self target] dragItemsAtIndexes:indexes toIndex:destIndex];         
    } else if ([dragTypes containsObject:NSFilenamesPboardType]) {
        NSArray *filePaths = [[sender draggingPasteboard]
            propertyListForType:NSFilenamesPboardType];
        [[self target] dragFiles:filePaths toIndex:destIndex];
    }
    return YES;
}


- (NSDragOperation)draggingUpdated: (id<NSDraggingInfo>)sender
{
    NSPoint dragPos = [[self superview] convertPoint:[sender draggingLocation]
                                           fromView:nil];
    NSView *targetView = [self hitTest:dragPos];

    NSDragOperation dragOperation = NSDragOperationNone;
    NSArray *dragTypes = [[sender draggingPasteboard] types];
    if ([dragTypes containsObject:DRAG_ITEM_TYPE]) {
        dragOperation = NSDragOperationMove;
    } else if ([dragTypes containsObject:NSFilenamesPboardType]) {
        NSArray *filePaths = [[sender draggingPasteboard]
            propertyListForType:NSFilenamesPboardType];
        if(self.target)
            dragOperation = [[self target] dragOperationForFiles:filePaths];
    }

    if (dragOperation == NSDragOperationNone) {
        [self setDragTarget:nil draggingInfo:sender];
    } else {
        [self setDragTarget:targetView draggingInfo:sender];
    }
    return dragOperation;
}


- (BOOL)wantsPeriodicDraggingUpdates
{
    return NO;
}


- (NSDragOperation)draggingSourceOperationMaskForLocal: (BOOL)isLocal
{
    if (isLocal) {
        return NSDragOperationMove;
    } else {
        return NSDragOperationLink;
    }
}


- (int)indexFromDragTarget: (NSView *)targetView
              draggingInfo: (id<NSDraggingInfo>)draggingInfo
{
    int index = NSNotFound;
    if (targetView &&
            [targetView isKindOfClass:[MGCollectionViewItem class]]) {
        index = [items indexOfObject:targetView];
    }

    if (index != NSNotFound) {
        MGCollectionViewItem *item =
            [items objectAtIndex:index];
        NSPoint viewPos = [item convertPoint:[draggingInfo draggingLocation]
                                    fromView:nil];
        NSRect bounds = [item bounds];
        if (viewPos.y < bounds.size.height / 2.0) {
            index = fmin(index + 1, [items count]);
        }
    }

    return index;
}


- (void)setDragTarget: (NSView *)targetView
         draggingInfo: (id<NSDraggingInfo>)draggingInfo
{
    int newDragTargetIndex = [self indexFromDragTarget:targetView
                                          draggingInfo:draggingInfo];
    int curDragTargetIndex = [self dragTargetIndex];
    if (newDragTargetIndex != curDragTargetIndex) {
        [self setIndex:curDragTargetIndex isDragTarget:NO];
        [self setIndex:newDragTargetIndex isDragTarget:YES];
    }
}


- (void)setIndex: (int)index
    isDragTarget: (BOOL)isDragTarget
{
    if (index != NSNotFound) {
        DragTargetType dragTargetType = isDragTarget ? DragTargetType_Top :
                                                       DragTargetType_None;
        int actualIndex = index;
        if (actualIndex == [items count]) {
            actualIndex = [items count] - 1;
            if (isDragTarget) {
                dragTargetType = DragTargetType_Bottom;
            }
        }
        [[items objectAtIndex:actualIndex] setDragTargetType:dragTargetType];
    }
}


- (id<MGCollectionViewTarget>)target
{
    return target;
}


- (int)dragTargetIndex
{
    int count = [items count];
    int i;
    for (i = 0; i < count; i++) {
        MGCollectionViewItem *item = [items objectAtIndex:i];
        if ([item dragTargetType] == DragTargetType_Top) {
            return i;
        } else if ([item dragTargetType] == DragTargetType_Bottom) {
            return i + 1;
        }
    }
    return NSNotFound;
}


- (void)resizeWithOldSuperviewSize: (NSSize)oldBoundsSize
{
    [super resizeWithOldSuperviewSize:oldBoundsSize];
    [self performSelector:@selector(maximizeViewWidth:) withObject:nil afterDelay:0.10];
    //[self maximizeViewWidth:nil];
}


- (void)maximizeViewWidth: (id)sender
{
    float width = [[[self enclosingScrollView] contentView] frame].size.width;
    NSRect myOldFrame = [self frame];
    if (myOldFrame.size.width != width) {
        [self setFrameSize:NSMakeSize(width, myOldFrame.size.height)];
        [self setNeedsDisplay:YES];
    }
}

- (void)onKeyWindowUpdated: (NSNotification *)notification
{
    NSLog(@"Updated window");
}

- (void)onKeyWindowChanged: (NSNotification *)notification
{
    [self setNeedsDisplay:YES];

    NSEnumerator *e = [items objectEnumerator];
    MGCollectionViewItem *item;
    while ((item = [e nextObject])) {
        [item updateHighlightState];
    }
}


- (void)testSelectionChanged: (NSIndexSet *)oldSelection
{
    BOOL didChange = NO;
    if (!oldSelection) {
        didChange = YES;
    } else {
        NSIndexSet *newSelection = [self selectionIndexes];
        didChange = ![oldSelection isEqualToIndexSet:newSelection];
    }

    if (didChange) {
        [[self target] onSelectionDidChange];
    }
}


- (NSArray *)filePathsForIndexes: (NSIndexSet *)indexes
{
    return [[self target] filePathsForIndexes:indexes];
}


@end // MGCollectionView (Private)


@implementation MGCollectionViewItem


- (void)dealloc
{
    [cachedTextColors release];
    cachedTextColors = nil;
    [super dealloc];
}

- (void)awakeFromNib
{
    [self setNextResponder:[self superview]];
}


- (void)drawRect: (NSRect)rect
{
    [super drawRect:rect];

    if ([self isSelected]) {
        if ([self shouldDrawSecondaryHighlight]) {
            [[NSColor grayColor] set];
        } else {
            [[NSColor blueColor] set];
        }
        NSRectFill(rect);
    }

    if (dragTargetType != DragTargetType_None) {
        NSRect dRect = [self bounds];
        if (dragTargetType == DragTargetType_Top) {
            dRect.origin.y = dRect.size.height - 2.0;
        }
        dRect.size.height = 2;
        [[NSColor blackColor] set];
        NSRectFill(dRect);
    }
}


@end // MGCollectionViewItem

@implementation MGCollectionViewItem (Private)


- (NSMenu *)menuForEvent:(NSEvent *)event
{
    if (![self isSelected]) {
        [[self collectionView] itemClicked:self event:event];
    }
    return [[self superview] menuForEvent:event];
}


- (NSView *)hitTest: (NSPoint)point
{
    NSView *result = [super hitTest:point];
    if (result && ![result isKindOfClass:[NSButton class]]) {
        return self;
    } else {
        return result;
    }
}


- (void)mouseDown: (NSEvent *)event
{
    if ([self isLeftClickEvent:event]) {
        mouseDownPos = [event locationInWindow];
    }
}


- (void)mouseUp: (NSEvent *)event
{
    if ([self isLeftClickEvent:event]) {
        [[self collectionView] itemClicked:self event:event];
    }
}


- (void)mouseDragged: (NSEvent *)event
{
    if ([self isLeftClickEvent:event]) {
        NSPoint mouseDragPos = [event locationInWindow];
        float distance = PointDistance(mouseDragPos, mouseDownPos);
        if (distance > DRAG_START_DISTANCE) {
            [[self collectionView] startDrag:event withItem:self];
        }
    }
}


- (BOOL)acceptsFirstResponder
{
    return NO;
}


- (void)setIsSelected: (BOOL)flag
{
    if (isSelected != flag) {
        isSelected = flag;
        [self updateHighlightState];
        [self setNeedsDisplay:YES];
    }
}


- (BOOL)isSelected
{
    return isSelected;
}


- (MGCollectionView *)collectionView
{
    ASSERT([[self superview] isKindOfClass:[MGCollectionView class]]);
    return (MGCollectionView *)[self superview];
}


- (BOOL)isLeftClickEvent: (NSEvent *)event
{
    return [event buttonNumber] == 0 &&
          ([event modifierFlags] & NSControlKeyMask) == 0;
}


- (void)setDragTargetType: (DragTargetType)type
{
    if (dragTargetType != type) {
        dragTargetType = type;
        [self setNeedsDisplay:YES];
    }
}


- (DragTargetType)dragTargetType
{
    return dragTargetType;
}


- (void)updateHighlightState
{
    BOOL isHighlighted = [self isSelected] &&
                        ![self shouldDrawSecondaryHighlight];

    NSEnumerator *e = [[self subviews] objectEnumerator];
    id subview;
    while ((subview = [e nextObject])) {
        if ([subview isKindOfClass:[NSTextField class]]) {
            [self setHighlight:isHighlighted
                forTextField:(NSTextField *)subview];                  
        } else if ([subview respondsToSelector:@selector(setIsSelected:)]) {
            [subview setIsSelected:isHighlighted];
        }
    }
}


- (void)setHighlight: (BOOL)isHighlighted
        forTextField: (NSTextField *)textField
{
    NSNumber *key = [NSNumber numberWithInt:[textField hash]];

    if (!cachedTextColors) {
        cachedTextColors = [[NSMutableDictionary alloc] init];
    }

    if (isHighlighted) {
        if (![cachedTextColors objectForKey:key]) {
            [cachedTextColors setObject:[textField textColor] forKey:key];
            [textField setTextColor:[NSColor whiteColor]];
        }
    } else {
        if ([cachedTextColors objectForKey:key]) {
            [textField setTextColor:[cachedTextColors objectForKey:key]];
            [cachedTextColors removeObjectForKey:key];
        }
    }
}


- (BOOL)shouldDrawSecondaryHighlight
{
    if ([[self window] isKeyWindow]) {
        return NO;
    } else {
        return YES;
    }
}


@end // MGCollectionViewItem (Private)