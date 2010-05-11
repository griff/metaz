//
//  TheTVDBSearchProvider.h
//  MetaZ
//
//  Created by Nigel Graham on 09/04/10.
//  Copyright 2010 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/MetaZKit.h>
#import "TheTVDBSearch.h"

@interface TheTVDBSearchProvider : MZBaseSearchProvider <MZSearchProvider>
{
    NSImage* icon;
    NSArray* supportedSearchTags;
    NSMenu* menu;
}

@end
