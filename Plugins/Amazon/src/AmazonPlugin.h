//
//  AmazonPlugin.h
//  MetaZ
//
//  Created by Brian Olsen on 16/11/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/MetaZKit.h>

@interface AmazonPlugin : MZSearchProviderPlugin
{
    NSArray* supportedSearchTags;
    NSMenu* menu;
}

@end
