//
//  AmazonSearcher.h
//  MetaZ
//
//  Created by Brian Olsen on 18/11/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/MetaZKit.h>

@interface AmazonSearchProvider : NSObject <MZSearchProvider>
{
    NSImage* icon;
    NSArray* supportedSearchTags;
    NSMenu* menu;
}

@end
