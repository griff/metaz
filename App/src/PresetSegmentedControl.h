//
//  PresetSegmentedControl.h
//  MetaZ
//
//  Created by Brian Olsen on 17/12/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PresetSegmentedControl : NSSegmentedControl
{
    NSMutableArray* segmentKeys;
}

- (void)setSegmentCount:(NSInteger)count;

- (NSString *)keyEquivalentForSegment:(NSInteger)segment;
- (NSUInteger)keyEquivalentModifierMaskForSegment:(NSInteger)segment;

- (void)setKeyEquivalent:(NSString *)charCode forSegment:(NSInteger)segment;
- (void)setKeyEquivalentModifierMask:(NSUInteger)mask forSegment:(NSInteger)segment;

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent;

@end
