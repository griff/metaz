//
//  MyTableView.h
//  MetaZ
//
//  Created by Brian Olsen on 02/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface FilesTableView : NSTableView {
    IBOutlet NSArrayController* filesController;    
}

-(IBAction)delete:(id)sender;
-(IBAction)beginEnterEdit:(id)sender;

@end
