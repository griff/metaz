//
//  MZArrayController.h
//  MetaZ
//
//  Created by Brian Olsen on 03/11/12.
//  Copyright 2012 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MZArrayController : NSArrayController {
    NSTimeInterval rearrangeDelay;
}
@property(assign) NSTimeInterval rearrangeDelay;

@end
