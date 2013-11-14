//
//  MGViewAnimation.m
//  Created by Matt Gemmell on 13/11/2006. http://mattgemmell.com/
//  Based on code by Todd Yandell http://tyandell.googlepages.com/
//  Includes bug fix by Joe Goh http://www.funkeemonk.com/funkeestory/
//

#import "MGViewAnimation.h"

@implementation MGViewAnimation


- (id)initWithViewAnimations:(NSArray*)viewAnimations
{
    if (self = [super initWithDuration:0.5 animationCurve:NSAnimationEaseInOut]) {
        [self setAnimationBlockingMode:NSAnimationNonblocking];
        
        _views = [[NSMutableArray alloc] initWithCapacity:[viewAnimations count]];
        _fadeViews = [[NSMutableDictionary alloc] initWithCapacity:0];
        _fadeImages = [[NSMutableDictionary alloc] initWithCapacity:0];
        
        [self setViewAnimations:viewAnimations];
        
        _continuouslyUpdatesFadingViews = YES;
        _ordersOutFadedWindows = YES;
        
        [self addProgressMark:1.0];
    }
    
    return self;
}


- (void)setViewAnimations:(NSArray *)viewAnimations
{
    // Ensure we have suitable start and end frames for every animation
    NSMutableArray *normalizedAnimations = [[NSMutableArray alloc] initWithCapacity:[viewAnimations count]];
    NSEnumerator *animationsEnum = [viewAnimations objectEnumerator];
    NSDictionary *nextAnimation;
    
    while (nextAnimation = [animationsEnum nextObject]) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:nextAnimation];
        id thisView;
        if ((thisView = [dict objectForKey:NSViewAnimationTargetKey])) {
            if ([thisView isKindOfClass:[NSWindow class]] || [thisView isKindOfClass:[NSView class]]) {
                [_views addObject:thisView];
                NSValue *viewFrameValue = [NSValue valueWithRect:[thisView frame]];
                if (![dict objectForKey:NSViewAnimationStartFrameKey]) {
                    [dict setObject:viewFrameValue forKey:NSViewAnimationStartFrameKey];
                }
                if (![dict objectForKey:NSViewAnimationEndFrameKey]) {
                    [dict setObject:viewFrameValue forKey:NSViewAnimationEndFrameKey];
                }
                [normalizedAnimations addObject:dict];
            }
        }
        [dict release];
    }
    
    _viewAnimations = normalizedAnimations; // already retained by init...: above
}


- (NSArray *)viewAnimations
{
    return _viewAnimations;
}


- (void)stopAnimation
{
    if ([self isAnimating]) {
        [super stopAnimation];
        [self setCurrentProgress:1.0];
    }
}


- (void)setCurrentProgress:(float)progress
{
    NSDisableScreenUpdates();
    [super setCurrentProgress:progress];
    
    NSEnumerator *viewEnum = [_views objectEnumerator];
    id nextTarget;
    NSMutableArray *superviews = [[NSMutableArray alloc] initWithCapacity:[_views count]];
    int i = 0;
    
    while (nextTarget = [viewEnum nextObject]) {
        NSRect newFrame = [self frameForView:(NSView *)nextTarget atProgress:[self currentValue]];
        if ([nextTarget isKindOfClass:[NSWindow class]]) {
            [(NSWindow *)nextTarget setFrame:newFrame display:YES];
        } else {
            [(NSView *)nextTarget setFrame:newFrame];
        }
        
        /*
         NSViewAnimationEffectKey
         An effect to apply to the animation.
         
         Takes a string constant specifying fade-in or fade-out effects for the target: 
         NSViewAnimationFadeInEffect and NSViewAnimationFadeOutEffect. If the target is 
         a view and the effect is to fade out, the view is hidden at the end. If the effect 
         is to fade in an initially hidden view and the end frame is non-empty, the view is 
         unhidden at the end. If the target is a window, the window is ordered in or out as 
         appropriate to the effect. This property is optional.
         */
        NSString *effectKey = [[_viewAnimations objectAtIndex:i] objectForKey:NSViewAnimationEffectKey];
        BOOL fadeOut = [effectKey isEqualToString:NSViewAnimationFadeOutEffect];
        if (effectKey) {
            NSString *key = [NSString stringWithFormat:@"%d", i];
            if ([nextTarget isKindOfClass:[NSView class]]) {
                NSView *nextView = (NSView *)nextTarget;
                if (progress == 1.0) {
                    // Destroy _fadeImage and _fadeView
                    [(NSImageView *)[_fadeViews objectForKey:key] removeFromSuperview];
                    [_fadeViews removeObjectForKey:key];
                    [_fadeImages removeObjectForKey:key];
                    
                    if (!fadeOut) {
                        [nextView setHidden:NO];
                    }
                } else if (![nextView isHidden] || ![_fadeViews objectForKey:key]) { // we always hide the view before starting a fade effect
                                                                                     // Create view image for this view and NSImageView to display it
                    NSImage *thisImg = [[NSImage alloc] initWithSize:[nextView bounds].size];
                    [thisImg setFlipped: [nextView isFlipped]];
                    [thisImg lockFocus];
                    // Make nextView draw itself into our image, even though it's hidden
                    [nextView drawRect:[nextView bounds]];
                    [thisImg unlockFocus];
                    [_fadeImages setObject:thisImg forKey:key];
                    [thisImg release];
                    
                    NSImageView *imgView = [[NSImageView alloc] initWithFrame:newFrame];
                    [imgView setImageFrameStyle:NSImageFrameNone];
                    [imgView setImageScaling:NSScaleNone];
                    if (fadeOut) {
                        [imgView setImage:thisImg];
                    }
                    [[nextView superview] addSubview:imgView positioned:NSWindowAbove relativeTo:nextView];
                    [_fadeViews setObject:imgView forKey:key];
                    [imgView release];
                    
                    [nextView setHidden:YES];
                } else {
                    // Create image representation of thisView
                    NSImage *thisViewImage = [[NSImage alloc] initWithSize:newFrame.size];
                    NSImage *thisImg;
                    if ([self continuouslyUpdatesFadingViews]) {
                        thisImg = [[[NSImage alloc] initWithSize:[nextView bounds].size] autorelease];
                        [thisImg setFlipped: [nextView isFlipped]];
                        [thisImg lockFocus];
                        // Make nextView draw itself into our image, even though it's hidden
                        [nextView drawRect:[nextView bounds]];
                        [thisImg unlockFocus];
                        // Update stored image
                        [_fadeImages setObject:thisImg forKey:key];
                    } else {
                        thisImg = (NSImage *)[_fadeImages objectForKey:key];
                    }
                    
                    float fraction = (fadeOut) ? 1.0 - progress : progress;
                    [thisViewImage lockFocus];
                    [thisImg compositeToPoint:NSZeroPoint operation:NSCompositeSourceOver fraction:fraction];
                    [thisViewImage unlockFocus];
                    
                    NSImageView *fadeView = (NSImageView *)[_fadeViews objectForKey:key];
                    [fadeView setImage:thisViewImage];
                    [fadeView setFrame:newFrame];
                    [thisViewImage release];
                }
            } else {
                // This is a window
                NSWindow *win = (NSWindow *)nextTarget;
                if (!fadeOut && ![win isVisible]) {
                    // Starting animation
                    [win setAlphaValue:0.0];
                    [win orderFront:nil];
                } else if (progress == 1.0 && fadeOut) {
                    // Finishing animation
                    [win setAlphaValue:0.0];
                    if ([self ordersOutFadedWindows]) {
                        [win orderOut:nil];
                    }
                } else {
                    [win setAlphaValue:(fadeOut) ? 1.0 - progress : progress];
                }
            }
        }
        
        if ([nextTarget isKindOfClass:[NSView class]]) {
            NSView *superview = [nextTarget superview];
            if (![superviews containsObject:superview]) {
                [superview setNeedsDisplay:YES];
                [superviews addObject:superview];
            }
        }        
        i++;
    }
    
    viewEnum = [superviews objectEnumerator];
    NSView *superview;
    while (superview = [viewEnum nextObject]) {
        [superview displayIfNeeded];
    }
    [superviews release];
    NSEnableScreenUpdates();
}


- (void)dealloc
{
    [_fadeViews release];
    [_fadeImages release];
    [_views release];
    [_viewAnimations release];
    [super dealloc];
}


- (NSRect)frameForView:(NSView *)view atProgress:(float)progress
{
    NSRect originalRect = [self originalFrameForView:view];
    NSRect destinationRect = [self destinationFrameForView:view];
    
    return NSMakeRect(
          round(originalRect.origin.x + ((destinationRect.origin.x - originalRect.origin.x) * progress)), 
          round(originalRect.origin.y + ((destinationRect.origin.y - originalRect.origin.y) * progress)), 
          originalRect.size.width + ((destinationRect.size.width - originalRect.size.width) * progress), 
          originalRect.size.height + ((destinationRect.size.height - originalRect.size.height) * progress));
}


- (NSRect)originalFrameForView:(NSView *)view
{
    NSEnumerator *infoEnum = [_viewAnimations objectEnumerator];
    NSDictionary *nextInfo;
    
    while (nextInfo = [infoEnum nextObject]) {
        if ([[nextInfo objectForKey:NSViewAnimationTargetKey] isEqual:view]) {
            return [[nextInfo objectForKey:NSViewAnimationStartFrameKey] rectValue];
        }
    }
    
    return NSZeroRect;
}


- (NSRect)destinationFrameForView:(NSView *)view
{
    NSEnumerator *infoEnum = [_viewAnimations objectEnumerator];
    NSDictionary *nextInfo;
    
    while (nextInfo = [infoEnum nextObject]) {
        if ([[nextInfo objectForKey:NSViewAnimationTargetKey] isEqual:view]) {
            return [[nextInfo objectForKey:NSViewAnimationEndFrameKey] rectValue];
        }
    }
    
    return NSZeroRect;
}


- (BOOL)continuouslyUpdatesFadingViews
{
    return _continuouslyUpdatesFadingViews;
}


- (void)setContinuouslyUpdateFadingViews:(BOOL)value
{
    _continuouslyUpdatesFadingViews = value;
}


- (BOOL)ordersOutFadedWindows
{
    return _ordersOutFadedWindows;
}


- (void)setOrdersOutFadedWindows:(BOOL)value
{
    _ordersOutFadedWindows = value;
}


@end
