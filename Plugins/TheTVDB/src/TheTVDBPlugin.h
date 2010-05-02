//
//  TheTVDBPlugin.h
//  MetaZ
//
//  Created by Nigel Graham on 09/04/10.
//  Copyright 2010 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/MetaZKit.h>

#define EpisodeQueryTagIdent @"episodeQuery"

@interface TheTVDBPlugin : MZPlugin
{
    NSArray* searchProviders;
}

- (id)init;
- (NSArray *)searchProviders;

@end
