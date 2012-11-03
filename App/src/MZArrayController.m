//
//  MZArrayController.m
//  MetaZ
//
//  Created by Brian Olsen on 03/11/12.
//  Copyright 2012 Maven-Group. All rights reserved.
//

#import "MZArrayController.h"


@implementation MZArrayController

- (void)reallyRearrangeObjects
{
    [super rearrangeObjects];
}

/**
 * This is delayed because otherwise when using the automaticallyRearrangesObjects
 * option and inline table view editing the table view will lose firstResponder
 * status when rearrangeObjects gets called.
 */
- (void)rearrangeObjects
{
    [self performSelector:@selector(reallyRearrangeObjects) withObject:nil afterDelay:0];
}

@end
