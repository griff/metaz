//
//  TheMovieDbPlugin.h
//  MetaZ
//
//  Created by Brian Olsen on 29/12/11.
//  Copyright 2011 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/MetaZKit.h>

#define TMDbIdTagIdent @"tmdbId"
#define TMDbURLTagIdent @"tmdbURL"


@interface TheMovieDbPlugin : MZSearchProviderPlugin
{
    NSArray* supportedSearchTags;
    NSMenu* menu;
}

@end
