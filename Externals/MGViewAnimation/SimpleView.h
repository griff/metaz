//
//  SimpleView.h
//  NSViewAnimation Test
//
//  Created by Matt Gemmell on 08/11/2006.
//  Copyright 2006 Magic Aubergine. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SimpleView : NSView {
	int tag;
	NSColor *backgroundColor;
}
- (void)setTag:(int)newTag;
- (int)tag;
- (void)setBackgroundColor:(NSColor *)color;
- (NSColor *)backgroundColor;

@end
