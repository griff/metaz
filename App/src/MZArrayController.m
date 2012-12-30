//
//  MZArrayController.m
//  MetaZ
//
//  Created by Brian Olsen on 03/11/12.
//  Copyright 2012 Maven-Group. All rights reserved.
//

#import "MZArrayController.h"


@implementation MZArrayController

- (id)initWithContent:(id)content
{
    self = [super initWithContent:content];
    if(self)
    {
        rearrangeDelay = 0.5;
    }
    return self;
}

#pragma mark - NSCoding implementation
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        rearrangeDelay = 0.5;
        if([aDecoder containsValueForKey:@"rearrangeDelay"])
            rearrangeDelay = [aDecoder decodeDoubleForKey:@"rearrangeDelay"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeDouble:rearrangeDelay forKey:@"rearrangeDelay"];
}

#pragma mark - rearrange delay

@synthesize rearrangeDelay;

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
    [self performSelector:@selector(reallyRearrangeObjects) withObject:nil afterDelay:self.rearrangeDelay];
}

@end
