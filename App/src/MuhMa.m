//
//  MuhMa.m
//  MetaZ
//
//  Created by Brian Olsen on 16/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "MuhMa.h"

@interface MuhMa (Private)
- (NSMutableArray*)_targetItems;
- (void)_applyTargetConfiguration:(BOOL)animate;
- (void)_contentChanged:(BOOL)changed regenerate:(BOOL)regenerate;
- (void)_computeTargetItemsByRegenerating:(BOOL)regenerate;
- (void)_animateAtEndOfEvent;
- (void)animationDidEnd:(NSAnimation *)animation;
@end

@interface MuhMaItem (Private) 
- (void)_finishHideAnimation;
- (NSRect)_targetViewFrameRect;
- (void)_setTargetViewFrameRect:(NSRect)frame;
- (BOOL)_isRemovalNeeded;
- (void)_setRemovalNeeded:(BOOL)needed;
- (void)_applyTargetConfigurationWithoutAnimation:(NSUInteger)index;
- (void)_applyTargetConfigurationWithAnimationMoveAndResize:(NSDictionary**)resize show:(NSDictionary**)show hide:(NSDictionary**)hide;
- (void)_copyConnectionsOfView:(NSView *)protoView referenceObject:(id)protoObject toView:(NSView *)view referenceObject:(id)object;
- (void)_setItemOwnerView:(MuhMa *)owner;
@end

@implementation MuhMa
@synthesize queues;
@synthesize collectionView;
@dynamic itemPrototype;
@dynamic content;

+ (void)initialize
{
    [self exposeBinding:NSContentBinding];
}

- (id)init
{
    self = [super init];
    if(self)
        _targetItems = [[NSMutableArray alloc] init];
    return self;
}

-(void)dealloc
{
    [queues release];
    [collectionView release];
    [itemPrototype release];
    [content release];
    [_animation release];
    [_targetItems release];
    [super dealloc];
}

-(void)awakeFromNib
{
    [self bind:NSContentBinding toObject:queues withKeyPath:@"arrangedObjects" options:nil];
    
}

- (NSMutableArray*)_targetItems
{
    return _targetItems;
}

- (MuhMaItem *)newItemForRepresentedObject:(id)object
{
    MuhMaItem* ret = [itemPrototype copy];
    [ret _setItemOwnerView:self];
    ret.representedObject = object;
    return ret;
}

- (void)animationDidEnd:(NSAnimation *)animation
{
    for(MuhMaItem* item in [NSArray arrayWithArray:_targetItems])
    {
        if([item _isRemovalNeeded])
            [item _finishHideAnimation];
    }

    [_animation release];
    _animation = nil;
}

- (void)_animateAtEndOfEvent
{
    [self _applyTargetConfiguration:YES];
}

- (void)_applyTargetConfiguration:(BOOL)animate
{
    NSArray* items = [NSArray arrayWithArray:_targetItems];
    if(animate)
    {
        BOOL needsObserver = NO;
        NSMutableArray* animations = [NSMutableArray arrayWithCapacity:[_targetItems count]];
        for(MuhMaItem* item in items)
        {
            NSDictionary* resize = nil;
            NSDictionary* show = nil;
            NSDictionary* hide = nil;
            [item _applyTargetConfigurationWithAnimationMoveAndResize:&resize show:&show hide:&hide];
            if(hide)
            {
                needsObserver = YES;
                [animations addObject:hide];
            } else if(show)
                [animations addObject:show];
            else if(resize)
                [animations addObject:resize];
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
        int idx = 0;
        for(MuhMaItem* item in items)
        {
            [item _applyTargetConfigurationWithoutAnimation:idx];
            if(![item _isRemovalNeeded])
                idx++;
        }
    }
}

- (void)_contentChanged:(BOOL)changed regenerate:(BOOL)regenerate
{
    [self _computeTargetItemsByRegenerating:regenerate];
}

- (void)_computeTargetItemsByRegenerating:(BOOL)regenerate
{
    NSMutableArray* existing = [NSMutableArray arrayWithCapacity:10];
    NSMutableIndexSet* foundSet = [[[NSMutableIndexSet alloc] init] autorelease];
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:10];
    NSUInteger len = [content count];
    NSUInteger len2 = [_targetItems count];
    for(NSUInteger y=0; y<len2; y++)
    {
        MuhMaItem* item = [_targetItems objectAtIndex:y];
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

    for(NSUInteger i=0; i<len;i++)
    {
        id object = [content objectAtIndex:i];
        if([foundSet containsIndex:i])
        {
            [existing addObject:[_targetItems objectAtIndex:[[dict objectForKey:[NSNumber numberWithUnsignedInt:i]] unsignedIntValue]]];
        } else  // Not Found = New Item
        {
            MuhMaItem* newItem = [self newItemForRepresentedObject:object];
            [existing addObject:newItem];
        }
    }
    [_targetItems release];
    _targetItems = [existing retain];

    //if(!regenerate)
    //    [self performSelector:@selector(_animateAtEndOfEvent) withObject:nil afterDelay:0.10];
    //else
        [self _applyTargetConfiguration:NO];
}

- (void)setContent:(NSArray *)aContent
{
    [content release];
    content = [[NSArray alloc] initWithArray:aContent];
    [self _contentChanged:YES regenerate:NO];
}

/*
- (NSArray *)content
{
    return content;
}
*/

- (void)setItemProtoType:(MuhMaItem *)item
{
    [itemPrototype release];
    itemPrototype = [item retain];
    [self _contentChanged:NO regenerate:YES];
}

@end

@implementation MuhMaItem
@dynamic parent;
@synthesize item;

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if(self)
    {
        self.view = [decoder decodeObjectForKey:@"view"];
        selected = [decoder decodeBoolForKey:@"selected"];
        _itemOwnerView = [[decoder decodeObjectForKey:@"_itemOwnerView"] retain];
        _removalNeeded = [decoder decodeBoolForKey:@"_removalNeeded"];
        _targetViewFrameRect = [decoder decodeRectForKey:@"_targetViewFrameRect"];
        item = [[decoder decodeObjectForKey:@"item"] retain];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeObject:self.view forKey:@"view"];
    [encoder encodeBool:selected forKey:@"selected"];
    [encoder encodeObject:_itemOwnerView forKey:@"_itemOwnerView"];
    [encoder encodeBool:_removalNeeded forKey:@"_removalNeeded"];
    [encoder encodeRect:_targetViewFrameRect forKey:@"_targetViewFrameRect"];
    [encoder encodeObject:item forKey:@"item"];
}

-(void)dealloc
{
    [_itemOwnerView release];
    [archived release];
    [item release];
    [super dealloc];
}

- (void)loadView
{
    [super loadView];
}

- (MuhMa *)parent
{
    return _itemOwnerView;
}

- (void)setSelected:(BOOL)flag
{
    selected = flag;
}

- (BOOL)isSelected
{
    return selected;
}

- (id)copyWithZone:(NSZone *)zone
{
    if(!archived)
        archived = [[NSKeyedArchiver archivedDataWithRootObject:self] retain];
    MuhMaItem* ret = [NSKeyedUnarchiver unarchiveObjectWithData:archived];
    NSRect frame = NSZeroRect;
    frame.size = self.view.frame.size;
    [ret->item release];
    ret->item = [[MGCollectionViewItem alloc] initWithFrame:frame];
    [ret->item addSubview:ret.view];
    ret->_targetViewFrameRect = frame;
    [ret setRepresentedObject:nil];
    [self _copyConnectionsOfView:[self view] referenceObject:self toView:[ret view] referenceObject:ret];
    return ret;
}

- (void)_finishHideAnimation
{
    [self retain];
    [[_itemOwnerView collectionView] removeObject:item];
    //[self.view removeFromSuperview];
    [[_itemOwnerView _targetItems] removeObject:self];
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

- (void)_setItemOwnerView:(MuhMa *)owner
{
    [_itemOwnerView release];
    _itemOwnerView = [owner retain];
}

- (void)_applyTargetConfigurationWithoutAnimation:(NSUInteger)index
{
    NSView* superview = [self.item superview];
    NSRect frame = [self.item frame];
    if(_removalNeeded)
    {
        if(superview)
            [self _finishHideAnimation];
    } else if(!superview)
    {
        //self.item.frame = _targetViewFrameRect;
        [_itemOwnerView.collectionView addItem:item atIndex:index];
        //[_itemOwnerView.collectionView addSubview:self.view];
        [self.item setNeedsDisplay:YES];
    } else //if(!NSEqualRects(frame, _targetViewFrameRect))
    {
        [_itemOwnerView.collectionView moveItem:item toIndex:index];
        //self.item.frame = _targetViewFrameRect;
        [self.item setNeedsDisplay:YES];
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
        [_itemOwnerView.collectionView addSubview:self.view];
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

- (void)_copyConnectionsOfView:(NSView *)protoView referenceObject:(id)protoObject toView:(NSView *)view referenceObject:(id)object
{
    if([protoView respondsToSelector:@selector(delegate)])
    {
        id theProtoView = protoView;
        id delegate = [theProtoView delegate];
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
        id theProtoView = protoView;
        id target = [theProtoView target];
        if(target)
        {
            id theView = view;
            id newTarget = [theView target];
            if(target == protoObject)
            {
                [theView setTarget:object];
                if([protoView respondsToSelector:@selector(action)])
                    [theView setAction:[theProtoView action]];
            }
            else if(!newTarget) // Only set to proto target if external from the encoding ei. new target is nil
            {
                [theView setTarget:target];
                if([protoView respondsToSelector:@selector(action)])
                    [theView setAction:[theProtoView action]];
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


@end


