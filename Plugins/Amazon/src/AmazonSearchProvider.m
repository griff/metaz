//
//  AmazonSearcher.m
//  MetaZ
//
//  Created by Brian Olsen on 18/11/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "AmazonSearchProvider.h"
#import "PlistMacros.h"

@implementation AmazonSearchProvider

- (void)dealloc
{
    //[search release];
    [icon release];
    [supportedSearchTags release];
    [menu release];
    [super dealloc];
}

- (NSImage *)icon
{
    if(!icon)
    {
        icon = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://www.amazon.com/favicon.ico"]];
    }
    return icon;
}

- (NSString *)identifier
{
    return @"org.maven-group.MetaZ.AmazonPlugin";
}

- (NSArray *)supportedSearchTags
{
    if(!supportedSearchTags)
    {
        NSMutableArray* ret = [NSMutableArray array];
        [ret addObject:[MZTag tagForIdentifier:MZTitleTagIdent]];
        [ret addObject:[MZTag tagForIdentifier:MZVideoTypeTagIdent]];
        [ret addObject:[MZTag tagForIdentifier:MZTVShowTagIdent]];
        [ret addObject:[MZTag tagForIdentifier:MZTVSeasonTagIdent]];
        supportedSearchTags = [[NSArray alloc] initWithArray:ret];
    }
    return supportedSearchTags;
}

@end
