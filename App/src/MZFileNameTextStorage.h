//
//  MZFileNameTextStorage.h
//  MetaZ
//
//  Created by Brian Olsen on 17/05/10.
//  Copyright 2010 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MZFileNameTextStorage : NSTextStorage
{
	NSMutableAttributedString* text;
    NSCharacterSet* wordSeperatorSet;
}

- (NSRange)doubleClickAtIndex:(NSUInteger)index;
- (NSUInteger)nextWordFromIndex:(NSUInteger)index forward:(BOOL)isForward;

@end
