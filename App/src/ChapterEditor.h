//
//  ChapterEditor.h
//  MetaZ
//
//  Created by Brian Olsen on 11/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FilesUndoController.h"
#import "MZApplyEditor.h"
#import "FilesArrayController.h"

@interface ChapterEditor : NSObject <MZApplyEditor> {
    NSSlider* slider;
    FilesArrayController* filesController;
    FilesUndoController* undoController;
    NSArray* editorChapters;
    NSArray* chapters;
    NSArray* chapterNames;
    NSInteger slide;
    NSInteger slideMin;
    NSInteger slideMax;
    NSNumber* cachedChanged;
    BOOL useCachedChanged;
}
@property (nonatomic,retain) IBOutlet NSSlider* slider;
@property (nonatomic,retain) IBOutlet FilesArrayController* filesController;
@property (nonatomic, retain) IBOutlet FilesUndoController* undoController;
@property (readonly) NSArray* editorChapters;
@property (nonatomic,retain) NSArray* chapters;
@property (nonatomic,retain) NSArray* chapterNames;
@property (readonly) BOOL chaptersChanged;
@property (assign) NSNumber* changed;
@property (assign) NSInteger slide;
@property (readonly) NSInteger slideMin;
@property (readonly) NSInteger slideMax;

- (BOOL)hideSlider;
- (void)itemChanged:(id)item;

@end
