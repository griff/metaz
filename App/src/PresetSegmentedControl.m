//
//  PresetSegmentedControl.m
//  MetaZ
//
//  Created by Brian Olsen on 17/12/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "PresetSegmentedControl.h"

@interface SegmentKeys : NSObject
{
    NSString* charCode;
    NSUInteger mask;
}
@property (retain) NSString* charCode;
@property NSUInteger mask;

+ (id)segment;

@end


@implementation PresetSegmentedControl

- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if(self && [self segmentCount] > 0)
        [self setSegmentCount:[self segmentCount]];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        if([self segmentCount] > 0)
            [self setSegmentCount:[self segmentCount]];
    }
    return self;
}

- (void)dealloc
{
    [segmentKeys release];
    [super dealloc];
}

- (void)setSegmentCount:(NSInteger)count
{
    [segmentKeys release];
    segmentKeys = [[NSMutableArray alloc] init];
    for(int i=0; i<count; i++)
        [segmentKeys addObject:[SegmentKeys segment]];
    [super setSegmentCount:count];
}

- (NSString *)keyEquivalentForSegment:(NSInteger)segmentNum
{
    SegmentKeys* segment = [segmentKeys objectAtIndex:segmentNum];
    return segment.charCode;
}

- (NSUInteger)keyEquivalentModifierMaskForSegment:(NSInteger)segmentNum
{
    SegmentKeys* segment = [segmentKeys objectAtIndex:segmentNum];
    return segment.mask;
}

- (void)setKeyEquivalent:(NSString *)charCode forSegment:(NSInteger)segmentNum
{
    SegmentKeys* segment = [segmentKeys objectAtIndex:segmentNum];
    segment.charCode = charCode;
}

- (void)setKeyEquivalentModifierMask:(NSUInteger)mask forSegment:(NSInteger)segmentNum
{
    SegmentKeys* segment = [segmentKeys objectAtIndex:segmentNum];
    segment.mask = mask;
}

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent
{
    NSString* charCode = [theEvent charactersIgnoringModifiers];
    NSUInteger modifierFlags = [theEvent modifierFlags] & NSDeviceIndependentModifierFlagsMask;

    NSInteger count = [self segmentCount];
    for(NSInteger i=0; i<count; i++)
    {
        if([self isEnabledForSegment:i])
        {
            SegmentKeys* segment = [segmentKeys objectAtIndex:i];
            if([segment.charCode isEqual:charCode] && segment.mask == modifierFlags)
            {
                NSSegmentSwitchTracking old = [[self cell] trackingMode];
                if(old == NSSegmentSwitchTrackingMomentary)
                    [[self cell] setTrackingMode:NSSegmentSwitchTrackingSelectOne];
                [self setSelectedSegment:i];
                [self sendAction:[self action] to:[self target]];
                if(old == NSSegmentSwitchTrackingMomentary)
                    [[self cell] setTrackingMode:old];
                return YES;
            }
        }
    }
    return [super performKeyEquivalent:theEvent];
}

@end

@implementation SegmentKeys

@synthesize charCode;
@synthesize mask;

+ (id)segment
{
    return [[[self alloc] init] autorelease];
}

@end

