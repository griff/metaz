//
//  FilesArrayController.h
//  MetaZ
//
//  Created by Brian Olsen on 08/11/12.
//  Copyright 2012 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MZArrayController.h"
#import "MZApplyEditor.h"

@interface FilesArrayController : MZArrayController <MZApplyController> {
    NSMutableArray* editors;
}

- (BOOL)canApply:(id)source;
- (void)apply:(id)source;

@end
