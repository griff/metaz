//
//  IMDBSearchProvider.h
//  MetaZ
//
//  Created by Brian Olsen on 23/12/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IMDBSearch.h"

@interface IMDBSearchProvider : NSObject<MZSearchProvider>
{
    IMDBSearch* search;
    NSImage* icon;
    NSArray* supportedSearchTags;
    NSMenu* menu;
}

@end
