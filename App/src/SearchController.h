//
//  SearchController.h
//  MetaZ
//
//  Created by Brian Olsen on 07/11/12.
//  Copyright 2012 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FilesArrayController.h"
#import "SearchProfile.h"

@interface SearchController : NSViewController <NSUserInterfaceValidations,MZPluginControllerDelegate>
{
    FilesArrayController* filesController;
    NSArrayController* arrayController;
    NSSearchField* searchField;
    NSProgressIndicator* searchIndicator;
    SearchProfile* activeProfile;
    NSInteger searches;
    NSView* placeholder;
    NSDictionary* currentSearchTerms;
}
@property (nonatomic, retain) IBOutlet NSArrayController* arrayController;
@property (nonatomic, retain) IBOutlet FilesArrayController* filesController;
@property (nonatomic, retain) IBOutlet NSSearchField* searchField;
@property (nonatomic, retain) IBOutlet NSProgressIndicator* searchIndicator;
@property (nonatomic, retain) IBOutlet NSView* placeholder;

- (IBAction)startSearch:(id)sender;
- (IBAction)selectNextResult:(id)sender;
- (IBAction)selectPreviousResult:(id)sender;
- (IBAction)applyResult:(id)sender;

@end
