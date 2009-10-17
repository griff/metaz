//
//  TCSearchProvider.h
//  MetaZ
//
//  Created by Brian Olsen on 11/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/MetaZKit.h>
#import "TCSearch.h"

@interface TCSearchProvider : NSObject <MZSearchProvider>
{
    TCSearch* search;
    NSImage* icon;
    NSArray* supportedSearchTags;
    NSMenu* menu;
}

@end
