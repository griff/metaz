//
//  ChaptersTableView.h
//  MetaZ
//
//  Created by Brian Olsen on 19/12/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ChapterEditor.h"
#import "UndoTableView.h"

@interface ChaptersTableView : UndoTableView
{
    ChapterEditor* editor;
    NSArrayController* filesController;
}
@property (nonatomic, retain) IBOutlet ChapterEditor* editor;
@property (nonatomic, retain) IBOutlet NSArrayController* filesController;

-(IBAction)copy:(id)sender;
-(IBAction)paste:(id)sender;

- (BOOL)validateUserInterfaceItem:(id < NSValidatedUserInterfaceItem >)anItem;

@end
