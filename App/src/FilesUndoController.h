//
//  UndoController.h
//  MetaZ
//
//  Created by Brian Olsen on 06/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/MetaZKit.h>

@interface FilesUndoController : NSObject {
    NSArrayController* filesController;
    NSUndoManager* multipleUndoManager;
    MetaEdits* selection;
}
@property (nonatomic, retain) IBOutlet NSArrayController* filesController;

-(NSUndoManager *)undoManager;

@end
