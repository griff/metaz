//
//  SimpleView.m
//  NSViewAnimation Test
//
//  Created by Matt Gemmell on 08/11/2006.
//  Copyright 2006 Magic Aubergine. All rights reserved.
//

#import "SimpleView.h"


@implementation SimpleView

- (id)initWithFrame:(NSRect)frame
{
	if (self = [super initWithFrame:frame]) {
		[self setBackgroundColor:[NSColor blueColor]];
	}
	return self;
}


- (void)drawRect:(NSRect)rect {
    [[self backgroundColor] set];
    NSRectFill(rect);
}


- (void)setTag:(int)newTag
{
	tag = newTag;
}


- (int)tag
{
	return tag;
}


- (void)setBackgroundColor:(NSColor *)color
{
	if (color != backgroundColor) {
		[backgroundColor release];
		backgroundColor = [color retain];
	}
}


- (NSColor *)backgroundColor
{
	return backgroundColor;
}


@end
