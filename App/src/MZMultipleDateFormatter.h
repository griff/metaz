//
//  MZMultipleDateFormatter.h
//  MetaZ
//
//  Created by Brian Olsen on 20/12/11.
//  Copyright 2011 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MZMultipleDateFormatter : NSDateFormatter {
    NSDateFormatter* utc;
    NSDateFormatter* iso8601;
}

-(id)init;

@end
