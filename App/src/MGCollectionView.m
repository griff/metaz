//
//  MGCollectionView.m
//  MetaZ
//
//  Created by Brian Olsen on 16/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "MGCollectionView.h"
#include <math.h>

#if defined(__LP64__) && __LP64__
#define MGFloatMax(x,y) fmax(x,y)
#else	/* !defined(__LP64__) || !__LP64__ */
#define MGFloatMax(x,y) fmaxf(x,y)
#endif	/* !defined(__LP64__) || !__LP64__ */


@interface MGCollectionView (Private)
- (void)_removeTargetItem:(MGCollectionViewItem*)item;
- (void)_applyTargetConfiguration:(BOOL)animate;
- (void)_contentChanged:(BOOL)changed regenerate:(BOOL)regenerate;
- (void)_computeTargetItemsByRegenerating:(BOOL)regenerate;
- (void)_animateAtEndOfEvent;
- (void)animationDidEnd:(NSAnimation *)animation;
- (void)layout;
- (void)layoutWithAnimation:(BOOL)animation;
@end

@interface MGCollectionViewItem (Private) 
- (void)_finishHideAnimation;
- (NSRect)_targetViewFrameRect;
- (void)_setTargetViewFrameRect:(NSRect)frame;
- (BOOL)_isRemovalNeeded;
- (void)_setRemovalNeeded:(BOOL)needed;
- (void)_applyTargetConfigurationWithoutAnimation;
- (void)_applyTargetConfigurationWithAnimationMoveAndResize:(NSDictionary**)resize show:(NSDictionary**)show hide:(NSDictionary**)hide;
- (void)_copyConnectionsOfView:(id)protoView referenceObject:(id)protoObject toView:(id)view referenceObject:(id)object;
- (void)_setItemOwnerView:(MGCollectionView *)owner;
@end

@implementation MGCollectionView
@dynamic itemPrototype;
@dynamic content;
@dynamic backgroundColors;
@dynamic usesAlternatingRowBackgroundColors;
@synthesize items;

+ (void)initialize
{
    [self exposeBinding:NSContentBinding];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        _targetItems = [[NSMutableArray alloc] initWithCapacity:0];
        items = [[NSArray array] retain];
        _targetViewFrameRect = frame;
        usesAlternatingRowBackgroundColors = YES;
    }
    return self;
}

-(void)dealloc
{
    [itemPrototype release];
    [content release];
    [_animation release];
    [_targetItems release];
    [items release];
    [super dealloc];
}

- (void)_removeTargetItem:(MGCollectionViewItem*)item
{
    [_targetItems removeObject:item];
}

- (MGCollectionViewItem *)newItemForRepresentedObject:(id)object
{
    MGCollectionViewItem* ret = [itemPrototype copy];
    [ret _setItemOwnerView:self];
    ret.representedObject = object;
    return [ret autorelease];
}

- (void)animationDidEnd:(NSAnimation *)animation
{
    for(MGCollectionViewItem* item in [NSArray arrayWithArray:_targetItems])
    {
        if([item _isRemovalNeeded])
            [item _finishHideAnimation];
    }

    [_animation release];
    _animation = nil;
    [self setNeedsDisplay:YES];
}

- (void)_animateAtEndOfEvent
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_animateAtEndOfEvent) object:nil];
    [self _applyTargetConfiguration:YES];
}

- (void)_applyTargetConfiguration:(BOOL)animate
{
    NSRect frame = self.frame;
    NSArray* itritems = [NSArray arrayWithArray:_targetItems];
    if(animate)
    {
        NSMutableArray* animations = [NSMutableArray arrayWithCapacity:[_targetItems count]];
        for(MGCollectionViewItem* item in itritems)
        {
            NSDictionary* resize = nil;
            NSDictionary* show = nil;
            NSDictionary* hide = nil;
            [item _applyTargetConfigurationWithAnimationMoveAndResize:&resize show:&show hide:&hide];
            if(hide)
                [animations addObject:hide];
            else if(show)
                [animations addObject:show];
            else if(resize)
                [animations addObject:resize];
        }
        if(!NSEqualRects(frame, _targetViewFrameRect))
        {
            NSArray *keys = [NSArray arrayWithObjects:NSViewAnimationTargetKey, NSViewAnimationStartFrameKey, NSViewAnimationEndFrameKey, nil];
            NSArray *objects = [NSArray arrayWithObjects:self, [NSValue valueWithRect:frame], [NSValue valueWithRect:_targetViewFrameRect], nil];
            [animations addObject:[NSDictionary dictionaryWithObjects:objects forKeys:keys]];
        }
        if(animations.count > 0)
        {
            [_animation release];
            _animation = [[NSViewAnimation alloc] initWithViewAnimations:animations];
            [_animation setDuration:0.5];    // half a second.
            [_animation setAnimationCurve:NSAnimationEaseIn];
            
            [_animation setAnimationBlockingMode:NSAnimationNonblocking];
            [_animation setDelegate:self];
            // Run the animation.
            [_animation startAnimation];
        }
    } else
    {
        [self setFrame: _targetViewFrameRect];
        for(MGCollectionViewItem* item in itritems)
            [item _applyTargetConfigurationWithoutAnimation];
        if(!NSEqualRects(frame, _targetViewFrameRect))
            [self setNeedsDisplay:YES];
    }
}

- (BOOL)isFlipped
{
    return YES;
}

- (void)resizeWithOldSuperviewSize:(NSSize)oldBoundsSize
{
    [super resizeWithOldSuperviewSize:oldBoundsSize];
    
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldBoundsSize
{
//    [super resizeSubviewsWithOldSize:oldBoundsSize];
    if(!_animation)
        [self layoutWithAnimation:NO];
}

- (void)_contentChanged:(BOOL)changed regenerate:(BOOL)regenerate
{
    [self _computeTargetItemsByRegenerating:regenerate];
    if(!regenerate)
        [self performSelector:@selector(_animateAtEndOfEvent) withObject:nil afterDelay:0.10];
    else
        [self _applyTargetConfiguration:NO];

}

- (void)_computeTargetItemsByRegenerating:(BOOL)regenerate
{
    NSMutableArray* existing = [NSMutableArray arrayWithCapacity:10];
    NSMutableArray* newitems = [NSMutableArray arrayWithCapacity:10];
    NSMutableIndexSet* foundSet = [[[NSMutableIndexSet alloc] init] autorelease];
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:10];
    NSUInteger len = [content count];
    NSUInteger len2 = [_targetItems count];
    for(NSUInteger y=0; y<len2; y++)
    {
        MGCollectionViewItem* item = [_targetItems objectAtIndex:y];
        id object = [item representedObject];
        BOOL found = NO;
        if(!regenerate)
        {
            for(NSUInteger i=0; i<len;i++)
            {
                id newObj = [content objectAtIndex:i];
                if(object == newObj)
                {
                    [foundSet addIndex:i];
                    [dict setObject:[NSNumber numberWithUnsignedInt:y] forKey:[NSNumber numberWithUnsignedInt:i]];
                    found = YES;
                    break;
                }
            }
        }
        if(!found)
        {
            [item _setRemovalNeeded:YES];
            [existing addObject:item];
        }
    }

    CGFloat yPos = 0;
    NSRect myFrame = self.frame;
    for(NSUInteger i=0; i<len;i++)
    {
        id object = [content objectAtIndex:i];
        MGCollectionViewItem* item;
        if([foundSet containsIndex:i])
        {
            item = [_targetItems objectAtIndex:[[dict objectForKey:[NSNumber numberWithUnsignedInt:i]] unsignedIntValue]];
        } else  // Not Found = New Item
        {
            item = [self newItemForRepresentedObject:object];
        }

        NSRect oldFrame = item.view.frame;
        NSRect frame = NSZeroRect;
        frame.origin.y = yPos;
        frame.origin.x = 0;
        frame.size.width = myFrame.size.width;
        frame.size.height = oldFrame.size.height;
        [item _setTargetViewFrameRect:frame];
        yPos += frame.size.height;

        [existing addObject:item];
        [newitems addObject:item];
    }
    
    NSScrollView* scrollView = [self enclosingScrollView];
    if([scrollView documentView] == self)
    {
        NSRect scrollFrame = [[scrollView contentView] frame];
        CGFloat width = scrollFrame.size.width;
        if(scrollFrame.size.height > yPos)
            yPos = scrollFrame.size.height;
        if([scrollView autohidesScrollers] && [scrollView horizontalScroller])
        {
            CGFloat scrollerWidth = [[[scrollView horizontalScroller] class] scrollerWidth];
            if(myFrame.size.height > scrollFrame.size.height) //scroller is visible
            {
                if(yPos == scrollFrame.size.height) // scroller is going to be hiden
                {
                    for(MGCollectionViewItem * item in existing)
                    {
                        if(![item _isRemovalNeeded])
                        {
                            NSRect oldFrame = [item _targetViewFrameRect];
                            oldFrame.size.width += scrollerWidth;
                            [item _setTargetViewFrameRect:oldFrame];
                        }
                    }
                    width += scrollerWidth;
                }
            } else // Scroller is invisible
            {
                if(yPos > scrollFrame.size.height) // scroller is going to be shown
                {
                    for(MGCollectionViewItem * item in existing)
                    {
                        if(![item _isRemovalNeeded])
                        {
                            NSRect oldFrame = [item _targetViewFrameRect];
                            oldFrame.size.width -= scrollerWidth;
                            [item _setTargetViewFrameRect:oldFrame];
                        }
                    }
                    width -= scrollerWidth;
                }
            }
        }
        // Resize the collection view to fit.
        _targetViewFrameRect = NSMakeRect(myFrame.origin.x, myFrame.origin.y, width, yPos);
    }

    [_targetItems release];
    _targetItems = [existing retain];
    [self setNeedsLayout:NO];
    [self willChangeValueForKey:@"items"];
    [items release];
    items = [[NSArray arrayWithArray:newitems] retain];
    [self didChangeValueForKey:@"items"];
}

- (id)representedObjectForView:(NSView *)view
{
    if(view == self || view == [[self window] contentView])
        return nil;
    for(MGCollectionViewItem* item in items)
    {
        if(item.view == view)
            return [item representedObject];
    }
    return [self representedObjectForView:[view superview]];
}

- (void)setContent:(NSArray *)aContent
{
    [content release];
    content = [[NSArray alloc] initWithArray:aContent];
    [self _contentChanged:YES regenerate:NO];
}

- (NSArray *)content
{
    return content;
}

- (void)setNeedsLayout: (BOOL)flag
{
    needsLayout = flag;
    if(needsLayout)
        [self performSelector:@selector(layout) withObject:nil afterDelay:0.10];
}


- (void)layout
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(layout) object:nil];
    [self layoutWithAnimation:YES];
}

- (void)layoutWithAnimation:(BOOL)animate
{
    [self _computeTargetItemsByRegenerating:NO];
    if(animate)
        [self performSelector:@selector(_animateAtEndOfEvent) withObject:nil afterDelay:0.10];
    else
        [self _applyTargetConfiguration:NO];
}

- (void)setBackgroundColors:(NSArray *)colors
{
    if(colors && [colors count] == 0)
        colors = nil;
    if((backgroundColors == nil && colors != nil) ||
        (backgroundColors != nil && colors == nil) ||
        (backgroundColors && colors && ![backgroundColors isEqualToArray:colors]))
    {
        [self setNeedsDisplay:YES];
    }
    [backgroundColors release];
    if(colors)
        backgroundColors = [NSArray arrayWithArray:colors];
    else
        backgroundColors = nil;
}

- (void)setUsesAlternatingRowBackgroundColors:(BOOL)useAlternatingRowColors
{
    if(!backgroundColors && usesAlternatingRowBackgroundColors!=useAlternatingRowColors)
        [self setNeedsDisplay:YES];
    usesAlternatingRowBackgroundColors = useAlternatingRowColors;
}

- (void)drawRect:(NSRect)rect
{
    if (needsLayout) {
        [self layout];
    }

    [super drawRect:rect];

    NSArray* colors = backgroundColors;
    if(!colors)
    {
        if(usesAlternatingRowBackgroundColors)
            colors = [NSColor controlAlternatingRowBackgroundColors];
        else
            colors = [NSArray arrayWithObject:[NSColor controlBackgroundColor]];
    }
    NSUInteger count = [colors count];
    NSAssert(count>0, @"We need colors");
    if(count == 1)
    {
        [[colors objectAtIndex:0] set];
        NSRectFill([self bounds]);
        return;
    }
    NSUInteger coloridx = 0;
    
    CGFloat ypos = 0;
    for(MGCollectionViewItem* item in _targetItems)
    {
        if(![item _isRemovalNeeded])
        {
            [[colors objectAtIndex:coloridx] set];
            NSRect frame = item.view.frame;
            ypos = MGFloatMax(ypos, frame.origin.y + frame.size.height);
            NSRectFill(frame);
            coloridx = (coloridx + 1) % count;
        }
     }
     
     NSRect bounds = self.bounds;
     if(bounds.size.height > ypos)
     {
        CGFloat height = self.itemPrototype.view.frame.size.height;
        NSUInteger missing = (bounds.size.height - ypos) / height;
        for(NSUInteger i=0; i<missing; i++)
        {
            [[colors objectAtIndex:coloridx] set];
            NSRect frame = NSZeroRect;
            frame.origin.y = ypos;
            frame.size.width = bounds.size.width;
            frame.size.height = height;
            NSRectFill(frame);
            ypos+=height;
            coloridx = (coloridx + 1) % count;
        }
        [[colors objectAtIndex:coloridx] set];
        NSRect frame = NSZeroRect;
        frame.origin.y = ypos;
        frame.size.width = bounds.size.width;
        frame.size.height = bounds.size.height - ypos;
        NSRectFill(frame);
        //coloridx = (coloridx + 1) % count;
     }
}

- (void)setItemPrototype:(MGCollectionViewItem *)item
{
    [itemPrototype release];
    itemPrototype = [item retain];
    [self _contentChanged:NO regenerate:YES];
}

- (MGCollectionViewItem*)itemPrototype
{
    return itemPrototype;
}

@end

@implementation MGCollectionViewItem
@dynamic collectionView;
@synthesize selected;

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if(self)
    {
        self.view = [decoder decodeObjectForKey:@"view"];
        selected = [decoder decodeBoolForKey:@"selected"];
        _itemOwnerView = [decoder decodeObjectForKey:@"_itemOwnerView"];
        _removalNeeded = [decoder decodeBoolForKey:@"_removalNeeded"];
        _targetViewFrameRect = [decoder decodeRectForKey:@"_targetViewFrameRect"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeObject:self.view forKey:@"view"];
    [encoder encodeBool:selected forKey:@"selected"];
    [encoder encodeConditionalObject:_itemOwnerView forKey:@"_itemOwnerView"];
    [encoder encodeBool:_removalNeeded forKey:@"_removalNeeded"];
    [encoder encodeRect:_targetViewFrameRect forKey:@"_targetViewFrameRect"];
}

-(void)dealloc
{
    [archived release];
    [super dealloc];
}

- (void)loadView
{
    [super loadView];
}

- (MGCollectionView *)collectionView
{
    return _itemOwnerView;
}

- (id)copyWithZone:(NSZone *)zone
{
    if(!archived)
        archived = [[NSKeyedArchiver archivedDataWithRootObject:self] retain];
    MGCollectionViewItem* ret = [[NSKeyedUnarchiver unarchiveObjectWithData:archived] retain];
    [ret setRepresentedObject:nil];
    [self _copyConnectionsOfView:[self view] referenceObject:self toView:[ret view] referenceObject:ret];
    return ret;
}

- (void)_finishHideAnimation
{
    [self retain];
    [self.view removeFromSuperview];
    [_itemOwnerView _removeTargetItem:self];
    [self release];
}

- (NSRect)_targetViewFrameRect
{
    return _targetViewFrameRect;
}

- (void)_setTargetViewFrameRect:(NSRect)frame
{
    _targetViewFrameRect = frame;
}

- (BOOL)_isRemovalNeeded
{
    return _removalNeeded;
}

- (void)_setRemovalNeeded:(BOOL)needed
{
    _removalNeeded = needed;
}

- (void)_setItemOwnerView:(MGCollectionView *)owner
{
    _itemOwnerView = owner;
}

- (void)_applyTargetConfigurationWithoutAnimation
{
    NSView* superview = [self.view superview];
    NSRect frame = [self.view frame];
    if(_removalNeeded)
    {
        if(superview)
            [self _finishHideAnimation];
    } else if(!superview)
    {
        self.view.frame = _targetViewFrameRect;
        [_itemOwnerView addSubview:self.view];
        [self.view setNeedsDisplay:YES];
    } else if(!NSEqualRects(frame, _targetViewFrameRect))
    {
        self.view.frame = _targetViewFrameRect;
        [self.view setNeedsDisplay:YES];
    }
}

- (void)_applyTargetConfigurationWithAnimationMoveAndResize:(NSDictionary**)resize show:(NSDictionary**)show hide:(NSDictionary**)hide
{
    NSView* superview = [self.view superview];
    NSRect frame = [self.view frame];
    if(_removalNeeded)
    {
        if(superview)
        {
            NSArray *keys = [NSArray arrayWithObjects:NSViewAnimationTargetKey, NSViewAnimationEffectKey, NSViewAnimationStartFrameKey, NSViewAnimationEndFrameKey, nil];
            NSArray *objects = [NSArray arrayWithObjects:self.view, NSViewAnimationFadeOutEffect, [NSValue valueWithRect:frame], [NSValue valueWithRect:frame], nil];
            *hide = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        }
    }
    else if(!superview)
    {
        [self.view setHidden:YES];
        [_itemOwnerView addSubview:self.view];
        //[self.view setFrame:_targetViewFrameRect];
        //[self.view setNeedsDisplay:NO];
        NSArray *keys = [NSArray arrayWithObjects:NSViewAnimationTargetKey, NSViewAnimationEffectKey, NSViewAnimationStartFrameKey, NSViewAnimationEndFrameKey, nil];
        NSArray *objects = [NSArray arrayWithObjects:self.view, NSViewAnimationFadeInEffect, [NSValue valueWithRect:_targetViewFrameRect], [NSValue valueWithRect:_targetViewFrameRect], nil];
        *show = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    }
    else if(!NSEqualRects(frame, _targetViewFrameRect))
    {
        NSArray *keys = [NSArray arrayWithObjects:NSViewAnimationTargetKey, NSViewAnimationStartFrameKey, NSViewAnimationEndFrameKey, nil];
        NSArray *objects = [NSArray arrayWithObjects:self.view, [NSValue valueWithRect:frame], [NSValue valueWithRect:_targetViewFrameRect], nil];
        *resize = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    }
}

- (void)_copyConnectionsOfView:(id)protoView referenceObject:(id)protoObject toView:(id)view referenceObject:(id)object
{
    if([protoView respondsToSelector:@selector(delegate)])
    {
        id delegate = [protoView delegate];
        if(delegate)
        {
            id theView = view;
            id newDelegate = [theView delegate];
            if(delegate == protoObject)
                [theView setDelegate:object];
            else if(!newDelegate) // Only set to proto delegate if external from the encoding ei. new delegate is nil
                [theView setDelegate:delegate];
        }
    }
    if([protoView respondsToSelector:@selector(target)])
    {
        id target = [protoView target];
        if(target)
        {
            id newTarget = [view target];
            if(target == protoObject)
            {
                [view setTarget:object];
                if([protoView respondsToSelector:@selector(action)])
                    [view setAction:[protoView action]];
            }
            else if(!newTarget) // Only set to proto target if external from the encoding ei. new target is nil
            {
                [view setTarget:target];
                if([protoView respondsToSelector:@selector(action)])
                    [view setAction:[protoView action]];
            }
        }
    }
    
    for(NSString* binding in [protoView exposedBindings])
    {
        NSDictionary* dict = [protoView infoForBinding:binding];
        if(dict)
        {
            id target = [[dict objectForKey:NSObservedObjectKey] valueForKeyPath:@"self"];
            NSDictionary* newDict = [view infoForBinding:binding];
            if(target == protoObject)
            {
                [view unbind:binding];
                [view      bind:binding
                       toObject:object 
                    withKeyPath:[dict objectForKey:NSObservedKeyPathKey]
                        options:[dict objectForKey:NSOptionsKey]];
            } else if(!newDict)
            {
                //id newTarget = [newDict objectForKey:NSObservedObjectKey];
                [view      bind:binding
                       toObject:target 
                    withKeyPath:[dict objectForKey:NSObservedKeyPathKey]
                        options:[dict objectForKey:NSOptionsKey]];
            }
        }
    }

    // TabViews need special handling
    if([protoView isKindOfClass:[NSTabView class]])
    {
        NSAssert([view isKindOfClass:[NSTabView class]], @"Both view and protoView must be NSTabView");

        NSArray* protoTabViewItems = [protoView tabViewItems];
        NSArray* tabViewItems = [view tabViewItems];
        NSAssert([protoTabViewItems count] == [tabViewItems count], @"Proto and view must have same number of tab items");
        
        NSEnumerator* eProto = [protoTabViewItems objectEnumerator];
        NSEnumerator* eSub = [tabViewItems objectEnumerator];
    
        id nextView = nil;
        id nextProto = nil;
        while( (nextView = [eSub nextObject]) && (nextProto = [eProto nextObject]) )
        {
            [self _copyConnectionsOfView:nextProto referenceObject:protoObject toView:nextView referenceObject:object];
        }
    }
    else
    {
        if(![protoView isKindOfClass:[NSView class]])
        {
            NSAssert(![view isKindOfClass:[NSView class]], @"Both view and protoView must not be NSView");
            if(![protoView respondsToSelector:@selector(view)])
                return;
            protoView = [protoView view];
            view = [view view];
            
            if(![protoView isKindOfClass:[NSView class]]) // Still not a view
                return;
        }
        NSArray* protoSubviews = [protoView subviews];
        NSArray* subviews = [view subviews];
        NSAssert([protoSubviews count] == [subviews count], @"Proto and view must have same number of subviews");

        NSEnumerator* eProto = [protoSubviews objectEnumerator];
        NSEnumerator* eSub = [subviews objectEnumerator];
    
        NSView* nextView = nil;
        NSView* nextProto = nil;
        while( (nextView = [eSub nextObject]) && (nextProto = [eProto nextObject]) )
        {
            [self _copyConnectionsOfView:nextProto referenceObject:protoObject toView:nextView referenceObject:object];
        }
    }
}


@end


