/*
 *  IKImageView-Missing.h
 *  MetaZ
 *
 *  Created by Brian Olsen on 26/09/09.
 *  Copyright 2009 Maven-Group. All rights reserved.
 *
 */

#import <Quartz/Quartz.h>

@interface IKImageView (Missing)
- (IBAction)crop:(id)sender;
- (void)setImage:(NSImage *)image;
- (BOOL) showsCheckerboard;
- (void) setShowsCheckerboard: (BOOL) showsCheckerboard;
@end

@interface IKImageState : NSObject
{
}
- (NSInteger)orientationTag;
- (CGFloat)rotationAngle;
@end

