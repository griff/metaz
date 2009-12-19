//
//  UKDockProgressIndicator.m
//  Doublette
//	LICENSE: MIT License
//
//  Created by Uli Kusterer on 30.04.05.
//  Copyright 2005 M. Uli Kusterer. All rights reserved.
//

// -----------------------------------------------------------------------------
//	Headers:
// -----------------------------------------------------------------------------

#import "UKDockProgressIndicator.h"


@implementation UKDockProgressIndicator

+ (void)initialize
{
    [self exposeBinding:@"minValue"];
    [self exposeBinding:@"maxValue"];
    [self exposeBinding:@"doubleValue"];
    [self exposeBinding:@"hidden"];
}

// -----------------------------------------------------------------------------
//	NSProgressIndicator-like methods:
// -----------------------------------------------------------------------------

-(void)     setMinValue: (double)mn
{
    min = mn;
    [progress setMinValue: mn];		// Call through to associated view if user wants us to.

    [self updateDockTile];
}

-(double)   minValue
{
    return min;
}


-(void)     setMaxValue: (double)mn
{
    max = mn;
    [progress setMaxValue: mn];		// Call through to associated view if user wants us to.

    [self updateDockTile];
}

-(double)   maxValue
{
    return max;
}


-(void)     setDoubleValue: (double)mn
{
    current = mn;
    [progress setDoubleValue: mn];		// Call through to associated view if user wants us to.
	
    [self updateDockTile];
}

-(double)   doubleValue
{
    return current;
}


-(void)     setNeedsDisplay: (BOOL)mn
{
    [progress setNeedsDisplay: mn];		// Call through to associated view if user wants us to.
}


-(void)     display
{
    [progress display];					// Call through to associated view if user wants us to.
}


-(void)     setHidden: (BOOL)flag
{
    [progress setHidden: flag];			// Call through to associated view if user wants us to.
    if( flag ) // Progress indicator is being hidden? Reset dock tile to regular icon again:
        [NSApp setApplicationIconImage: [NSImage imageNamed: @"NSApplicationIcon"]];
}

-(BOOL)     isHidden
{
    return [progress isHidden];
}


// -----------------------------------------------------------------------------
//	updateDockTile:
//		Main drawing bottleneck. This takes our min, max and current values and
//		draws them onto the dock tile. If the MiniProgressGradient.png image is
//		present, this stretches that image to draw the progress bar.
//
//		If no image is present this falls back on the knob color.
// -----------------------------------------------------------------------------

-(void) updateDockTile
{
    NSImage* dockIcon = [[[NSImage alloc] initWithSize: NSMakeSize(128,128)] autorelease];


    [dockIcon lockFocus];
    NSRect box = { {4, 4}, {120, 16} };
    
    // App icon:
    [[NSImage imageNamed: @"NSApplicationIcon"] dissolveToPoint: NSZeroPoint fraction: 1.0];
    
    // Track & Outline:
    [[NSColor whiteColor] set];
    [NSBezierPath fillRect: box];
    
    [[NSColor blackColor] set];
    [NSBezierPath strokeRect: box];
    
    // State fill:
    box = NSInsetRect( box, 1, 1 );
    [[NSColor knobColor] set];
    
    box.size.width = (box.size.width / (max -min)) * (current -min);
    
    NSImage* prImg = [NSImage imageNamed: @"MiniProgressGradient"];
    NSRect picBox = { { 0,0 }, { 0,0 } };
    if( prImg )
    {
        picBox.size = [prImg size];
        [prImg drawInRect: box fromRect: picBox operation: NSCompositeCopy fraction: 1.0];
    }
    else
        NSRectFill( box );
    [dockIcon unlockFocus];
    
    [NSApp setApplicationIconImage: dockIcon];
}

@end
