//
//  MZViewAnimation.m
//  MetaZ
//
//  Created by Brian Olsen on 22/08/11.
//  Copyright 2011 Maven-Group. All rights reserved.
//

#import "MZViewAnimation.h"

@interface MZViewAnimation()
@property(retain) NSAnimation* startAnimationLink;
@property(retain) NSAnimation* stopAnimationLink;
@end

@implementation MZViewAnimation
@synthesize startAnimationLink;
@synthesize stopAnimationLink;

- (void)dealloc
{
    self.startAnimationLink = nil;
    self.stopAnimationLink = nil;
    [super dealloc];
}

- (void)stopAnimationChain;
{
    NSAnimation* link = self.startAnimationLink;
    if(link)
    {
        if([link respondsToSelector:@selector(stopAnimationChain)])
            [link performSelector:@selector(stopAnimationChain)];
        else
            [link stopAnimation];
    }
    [self stopAnimation];
}

- (void)stopAnimation;
{
    [super stopAnimation];
}

- (void)startWhenAnimation:(NSAnimation *)animation reachesProgress:(NSAnimationProgress)startProgress
{
    [super startWhenAnimation:animation reachesProgress:startProgress];
    self.startAnimationLink = animation;
}

- (void)stopWhenAnimation:(NSAnimation *)animation reachesProgress:(NSAnimationProgress)stopProgress
{
    [super stopWhenAnimation:animation reachesProgress:stopProgress];
    self.stopAnimationLink = animation;
}

- (void)clearStartAnimation
{
    self.startAnimationLink = nil;
    [super clearStartAnimation];
}

- (void)clearStopAnimation
{
    self.stopAnimationLink = nil;
    [super clearStopAnimation];
}

@end
