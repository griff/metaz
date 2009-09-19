//
//  ImageWindowController.m
//  MetaZ
//
//  Created by Brian Olsen on 16/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "ImageWindowController.h"

#define IMAGE_CTX "imageCtx"
#define IMAGE_CTX2 "imageCtx2"

extern NSString *const IKToolModeSelectEllipse;
extern NSString *const IKToolModeSelectLasso;

@interface IKImageView (Missing)
- (IBAction)crop:(id)sender;
- (void)setImage:(NSImage *)image;
- (BOOL) showsCheckerboard;
- (void) setShowsCheckerboard: (BOOL) showsCheckerboard;
@end

NSData* tiffForCGImage(CGImageRef cgImage) {
  NSBitmapImageRep *imageRep = [[[NSBitmapImageRep alloc] initWithCGImage:cgImage] autorelease];
  NSData *tiffData = [imageRep TIFFRepresentationUsingCompression:NSTIFFCompressionLZW factor:0.0f];
  return tiffData;
}

@implementation ImageWindowController
@synthesize imageView;
@synthesize moveSelectTool;
@synthesize selectMenu;

+(NSImage*)rotateImage:(NSImageRep*)orig byDegrees:(CGFloat)deg{
	NSImage *rotated = [[NSImage alloc] initWithSize:[orig size]];
	[rotated lockFocus];
	NSAffineTransform *transform = [NSAffineTransform transform];
	[transform rotateByDegrees:deg];
	[transform concat];
	[orig drawAtPoint:NSZeroPoint];
	[rotated unlockFocus];
	[orig autorelease];
	return [rotated autorelease];
}


- (id)initWithImageView:(NSImageView *)aImageView
{
    self = [super initWithWindowNibName:@"ImageEdit"];
    sourceImageView = [aImageView retain];
    [sourceImageView addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:IMAGE_CTX];
    currentSelect = IKToolModeSelect;
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
        [imageView removeObserver:self forKeyPath:@"image"];
        [imageView setImage:[sourceImageView image]];
        [imageView addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:IMAGE_CTX2];
    }
}

- (void)imageDidChange:(IKImageView *)imageView imageState:(id)state image:(CGImageRef)image
//- (void)imageDidChange:(IKImageView *)aImageView
{
    NSDictionary* imageProps = imageView.imageProperties;
    for(NSString* key in [imageProps allKeys])
        NSLog(@"Key %@ Value %@", key, [imageProps objectForKey:key]);
    [sourceImageView removeObserver:self forKeyPath:@"image"];
    [sourceImageView setImage:[ImageWindowController rotateImage:[[NSBitmapImageRep alloc] initWithCGImage:[imageView image]]
                                                       byDegrees:imageView.rotationAngle]];
    [sourceImageView addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:IMAGE_CTX];
}

- (void)awakeFromNib
{
    [imageView setImage:[sourceImageView image]];
    imageView.editable = YES;
    imageView.supportsDragAndDrop = YES;
    imageView.hasVerticalScroller = YES;
    imageView.hasHorizontalScroller = YES;
    imageView.autohidesScrollers = YES;
    imageView.currentToolMode = IKToolModeMove;
    imageView.doubleClickOpensImageEditPanel = YES;
    imageView.showsCheckerboard = YES;
    [[IKImageEditPanel sharedImageEditPanel] setHidesOnDeactivate: YES];
    [moveSelectTool setMenu:selectMenu forSegment:1];
    imageView.delegate = self;
}

- (IBAction)crop:(id)sender
{
    [imageView crop:sender];
}

- (IBAction)moveSelect:(id)sender
{
    NSInteger idx = [moveSelectTool selectedSegment];
    if(idx == 0)
        imageView.currentToolMode = IKToolModeMove;
    else
        imageView.currentToolMode = currentSelect;
}

- (IBAction)selectRectangle:(id)sender
{
    [moveSelectTool setSelectedSegment:1];
    currentSelect = IKToolModeSelect;
    imageView.currentToolMode = currentSelect;
}

- (IBAction)selectEllipse:(id)sender
{
    [moveSelectTool setSelectedSegment:1];
    currentSelect = IKToolModeSelectEllipse;
    imageView.currentToolMode = currentSelect;
}

- (IBAction)selectLasso:(id)sender
{
    [moveSelectTool setSelectedSegment:1];
    currentSelect = IKToolModeSelectLasso;
    imageView.currentToolMode = currentSelect;
}

@end
