//
//  MetaEditPanel.m
//  MetaZ
//
//  Created by Brian Olsen on 06/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "MetaEditPanel.h"


@implementation MetaEditPanel
@synthesize undoController;

-(void)dealloc {
    [undoController release];
    [super dealloc];
}

-(NSUndoManager *)undoManager {
    NSUndoManager* man = [undoController undoManager];
    if(man != nil)
        return man;
    return [super undoManager];
}

@end
