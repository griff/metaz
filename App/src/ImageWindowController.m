//
//  ImageWindowController.m
//  MetaZ
//
//  Created by Brian Olsen on 16/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "ImageWindowController.h"

#define IMAGE_CTX "imageCtx"

@interface IKImageView (Missing)
- (void)setImage:(NSImage *)image;
@end

@implementation ImageWindowController
@synthesize imageView;
@synthesize moveSelectTool;
@synthesize selectMenu;

- (id)initWithImageView:(NSImageView *)aImageView
{
    self = [super initWithWindowNibName:@"ImageEdit"];
    sourceImageView = [aImageView retain];
    [sourceImageView addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:IMAGE_CTX];
    return self;
}

- (void)dealloc
{
    [sourceImageView removeObserver:self forKeyPath:@"image"];
    [sourceImageView release];
    [imageView release];
    [moveSelectTool release];
    [selectMenu release];
    [super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(context == IMAGE_CTX && object == sourceImageView && [keyPath isEqual:@"image"] && imageView)
    {
        [imageView setImage:[sourceImageView image]];
    }
}

- (void)awakeFromNib
{
    [imageView setImage:[sourceImageView image]];
    imageView.hasVerticalScroller = YES;
    imageView.hasHorizontalScroller = YES;
    imageView.autohidesScrollers = YES;
    [moveSelectTool setMenu:selectMenu forSegment:1];
}

@end
