//
//  ImageWindowController.h
//  MetaZ
//
//  Created by Brian Olsen on 16/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@interface ImageWindowController : NSWindowController {
    IKImageView* imageView;
    NSImageView* sourceImageView;
    NSSegmentedControl* moveSelectTool;
    NSMenu* selectMenu;
}
@property (nonatomic, retain) IBOutlet IKImageView* imageView;
@property (nonatomic, retain) IBOutlet NSSegmentedControl* moveSelectTool;
@property (nonatomic, retain) IBOutlet NSMenu* selectMenu;

- (id)initWithImageView:(NSImageView *)aImageView;

@end
