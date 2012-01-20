//
//  TheMovieDbSearchProvider.h
//  MetaZ
//
//  Created by Brian Olsen on 30/12/11.
//  Copyright 2011 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/MetaZKit.h>

@interface TheMovieDbSearchProvider : MZBaseSearchProvider <MZSearchProvider>
{
    NSImage* icon;
    NSArray* supportedSearchTags;
    NSMenu* menu;
}

@end
