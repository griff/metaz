//
//  IMDBPlugin.h
//  MetaZ
//
//  Created by Brian Olsen on 20/12/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/MetaZKit.h>

@interface IMDBPlugin : MZPlugin
{
    NSArray* searchProviders;
}

- (void)didLoad;

- (NSArray *)searchProviders;

@end
