//
//  MZTag.h
//  MetaZ
//
//  Created by Brian Olsen on 23/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MZTag : NSObject {

}

+ (NSArray*)infoTags;
+ (NSArray*)videoTags;
+ (NSArray*)sortTags;
+ (NSArray*)advancedTags;
+ (NSArray*)allKnownTags;

@end
