//
//  MZViewAnimation.h
//  MetaZ
//
//  Created by Brian Olsen on 22/08/11.
//  Copyright 2011 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MGViewAnimation.h"

@interface MZViewAnimation : MGViewAnimation
{
    NSAnimation* startAnimationLink;
    NSAnimation* stopAnimationLink;
}
@property(readonly,retain) NSAnimation* startAnimationLink;
@property(readonly,retain) NSAnimation* stopAnimationLink;

- (void)stopAnimationChain;

@end
