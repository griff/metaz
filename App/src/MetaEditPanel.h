//
//  MetaEditPanel.h
//  MetaZ
//
//  Created by Brian Olsen on 06/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FilesUndoController.h"

@interface MetaEditPanel : NSTabView {
    FilesUndoController* undoController;
}
@property (nonatomic, retain) IBOutlet FilesUndoController* undoController;

@end
