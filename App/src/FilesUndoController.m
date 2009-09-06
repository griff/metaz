//
//  UndoController.m
//  MetaZ
//
//  Created by Brian Olsen on 06/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "FilesUndoController.h"


@implementation FilesUndoController
@synthesize filesController;

#pragma mark - initialization
-(void)awakeFromNib {
    [filesController addObserver:self
                      forKeyPath:@"selection.self"
                         options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld|NSKeyValueObservingOptionInitial
                         context:nil];
}

-(void)dealloc {
    [filesController removeObserver:self forKeyPath:@"selection.self"];
    if(multipleUndoManager) [multipleUndoManager release];
    if(selection) [selection release];
    [filesController release];
    [super dealloc];
}

#pragma mark - as observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if(object == filesController && [@"selection.self" isEqual:keyPath])
    {
        if(selection)
        {
            [selection release];
            selection = nil;
        }
        //id newValue = [change objectForKey:NSKeyValueChangeNewKey];
        //id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
        id value = [filesController valueForKeyPath:@"selection.self"];
        if(value != NSMultipleValuesMarker && value != NSNoSelectionMarker && value != NSNotApplicableMarker)
            selection = [value retain];
    } else
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

#pragma mark - implementation

-(NSUndoManager *)undoManager; {
    if(multipleUndoManager!=nil)
        return multipleUndoManager;
    if(selection)
        return [selection undoManager];
    return nil;
}
@end
