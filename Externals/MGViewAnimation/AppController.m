//
//  AppController.m
//  NSViewAnimation Test
//
//  Created by Matt Gemmell on 08/11/2006.
//  Copyright 2006 Magic Aubergine.
//

#import "AppController.h"
#import "SimpleView.h"

@implementation AppController


- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)app
{
    return YES;
}


- (void)awakeFromNib
{
    moved = NO;
    
    // Add some views to the window
    NSRect baseRect = NSMakeRect(15, 128, 128, 128);
    NSArray *colors = [NSArray arrayWithObjects:[NSColor redColor], [NSColor greenColor], [NSColor blueColor], [NSColor yellowColor], nil];
    int i;
    for (i = 0; i < 4; i++) {
        NSRect rect = baseRect;
        rect.origin.x += i * (rect.size.width + 5.0);
        if (i == 3) {
            rect.origin.y -= 128;
        }
        SimpleView *view = [[SimpleView alloc] initWithFrame:rect];
        [view setTag:i];
        [view setBackgroundColor:[colors objectAtIndex:i]];
        [[window contentView] addSubview:view];
        [view release]; // window's contentView has retained it
    }
}


- (void)dealloc
{
    if (animation) {
        [animation stopAnimation];
        [animation release];
    }
    [super dealloc];
}


- (IBAction)animate:(id)sender
{
    if (animation) {
        [animation stopAnimation];
        [animation release];
        animation = nil;
    }
    
    // Move views either right or left depending on what we did last time
    int numViews = [[[window contentView] subviews] count];
    NSMutableArray *anims = [NSMutableArray arrayWithCapacity:numViews];
    
    int i;
    for (i = 0; i < numViews; i++) {
        NSView *thisView = [[[window contentView] subviews] objectAtIndex:i];
        if ([thisView isMemberOfClass:[SimpleView class]]) {
            NSRect viewRect = [thisView frame];
            float increase = 110.0;
            viewRect.origin.x += (moved) ? -((i-2) * increase + 5.0) : ((i-2) * increase + 5.0);
            viewRect.size.width += (moved) ? -increase : increase;
            NSDictionary *thisDict;
            if ([thisView tag] != 3) {
                thisDict = [NSDictionary dictionaryWithObjectsAndKeys:	thisView, 
                    NSViewAnimationTargetKey, 
                    [NSValue valueWithRect:viewRect], 
                    NSViewAnimationEndFrameKey,
                    nil];
            } else {
                thisDict = [NSDictionary dictionaryWithObjectsAndKeys:	thisView, 
                    NSViewAnimationTargetKey, 
                    [NSValue valueWithRect:[thisView frame]], 
                    NSViewAnimationEndFrameKey,
                               (moved) ? NSViewAnimationFadeInEffect : NSViewAnimationFadeOutEffect, 
                    NSViewAnimationEffectKey, 
                    nil];
            }
            [anims addObject:thisDict];
        }
    }
    
    if (NO) { // whether or not to animate the window's frame too
        NSRect windowRect = [window frame];
        float widthChange = 240.0;
        windowRect.size.width += (moved) ? widthChange : -widthChange;
        [anims addObject:[NSDictionary dictionaryWithObjectsAndKeys:window, 
            NSViewAnimationTargetKey, 
            [NSValue valueWithRect:windowRect], 
            NSViewAnimationEndFrameKey, 
            nil]];
    }
    
    if ([checkbox state] == NSOnState) {
        animation = [[NSViewAnimation alloc] initWithViewAnimations:anims];
    } else {
        animation = [[MGViewAnimation alloc] initWithViewAnimations:anims];
        
        // For convenience during this demo
        [(MGViewAnimation *)animation setOrdersOutFadedWindows:NO];
        // Optimization we can use since our views don't change during animation
        [(MGViewAnimation *)animation setContinuouslyUpdateFadingViews:NO];
    }
    [animation setAnimationBlockingMode:NSAnimationBlocking];
    [animation setDuration:1.0]; // default is 0.5 (seconds)
    [animation startAnimation];
    
    moved = !moved;
}


@end
