//
//  TagChimpPlugin.h
//  MetaZ
//
//  Created by Brian Olsen on 11/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/MetaZKit.h>

#define TagChimpIdTagIdent @"tagChimpId"

@interface TagChimpPlugin : MZPlugin {
    NSArray* searchProviders;
}

- (id)init;
- (NSArray *)searchProviders;

@end
