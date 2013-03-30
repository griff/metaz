//
//  MZPlugin-Private.h
//  MetaZ
//
//  Created by Brian Olsen on 27/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/MZPlugin.h>

#define DISABLED_KEY @"disabledPlugins"

@interface MZPlugin ()
- (BOOL)isBuiltIn;
- (BOOL)canUnload;
- (BOOL)unload;
@end
