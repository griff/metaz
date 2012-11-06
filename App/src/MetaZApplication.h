//
//  NSApplication+MetaZApplication.h
//  MetaZ
//
//  Created by Brian Olsen on 14/07/12.
//  Copyright 2012 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MetaZApplication : NSApplication {
    NSMutableArray* documents;
    NSArrayController* filesController;
}
@property(retain) IBOutlet NSArrayController* filesController; 
@property(retain) id selection;

- (id)selectedDocuments;
- (id)handleOpenScriptCommand:(id)command;
- (NSArray *)queueDocuments;

@end
