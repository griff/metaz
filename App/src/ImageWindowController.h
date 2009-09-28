//
//  ImageWindowController.h
//  MetaZ
//
//  Created by Brian Olsen on 16/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IKImageView-Missing.h"

@interface ImageWindowController : NSWindowController {
    IKImageView* imageView;
    NSImageView* sourceImageView;
    NSSegmentedControl* moveSelectTool;
    NSMenu* selectMenu;
    NSString* currentSelect;
}
@property (nonatomic, retain) IBOutlet IKImageView* imageView;
@property (nonatomic, retain) IBOutlet NSSegmentedControl* moveSelectTool;
@property (nonatomic, retain) IBOutlet NSMenu* selectMenu;

- (IBAction)crop:(id)sender;
- (IBAction)moveSelect:(id)sender;
- (IBAction)selectRectangle:(id)sender;
- (IBAction)selectEllipse:(id)sender;
- (IBAction)selectLasso:(id)sender;

- (id)initWithImageView:(NSImageView *)aImageView;
//- (void)imageDidChange:(IKImageView *)imageView; 
- (void)imageDidChange:(IKImageView *)imageView imageState:(IKImageState*)state image:(CGImageRef)image; 
@end
