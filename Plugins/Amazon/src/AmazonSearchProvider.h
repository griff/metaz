//
//  AmazonSearcher.h
//  MetaZ
//
//  Created by Brian Olsen on 18/11/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/MetaZKit.h>
#import "AmazonSearch.h"

@interface AmazonSearchProvider : MZBaseSearchProvider <MZSearchProvider>
{
    NSImage* icon;
    NSArray* supportedSearchTags;
    NSMenu* menu;
}

@end
