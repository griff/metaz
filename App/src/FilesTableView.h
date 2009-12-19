//
//  MyTableView.h
//  MetaZ
//
//  Created by Brian Olsen on 02/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FilesUndoController.h"
#import "UndoTableView.h"

@interface FilesTableView : UndoTableView {
    NSArrayController* filesController;
    FilesUndoController* undoController;
}
@property (nonatomic, retain) IBOutlet FilesUndoController* undoController;
@property (nonatomic, retain) IBOutlet NSArrayController* filesController;

+ (void)initialize;

-(IBAction)delete:(id)sender;
-(IBAction)copy:(id)sender;
-(IBAction)paste:(id)sender;

@end
