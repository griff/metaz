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
-(void)awakeFromNib
{
    [filesController
        addObserver:self
         forKeyPath:@"selectedObjects"
            options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld|NSKeyValueObservingOptionInitial
            context:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [filesController removeObserver:self forKeyPath:@"selectedObjects"];
    [multipleUndoManager release];
    [selection release];
    [filesController release];
    [super dealloc];
}

#pragma mark - as observer

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if(object == filesController && [@"selectedObjects" isEqual:keyPath])
    {
        for(MetaEdits* edit in selected)
        {
            [[NSNotificationCenter defaultCenter]
                removeObserver:self
                          name:MZUndoActionNameNotification
                        object:[edit undoManager]];
            [[NSNotificationCenter defaultCenter]
                removeObserver:self
                          name:NSUndoManagerDidOpenUndoGroupNotification
                        object:[edit undoManager]];
            [[NSNotificationCenter defaultCenter]
                removeObserver:self
                          name:NSUndoManagerDidRedoChangeNotification
                        object:[edit undoManager]];
            [[NSNotificationCenter defaultCenter]
                removeObserver:self
                          name:NSUndoManagerDidUndoChangeNotification
                        object:[edit undoManager]];
        }
        [multipleUndoManager release];
        multipleUndoManager = nil;
        [selected release];
        selected = nil;
        [selection release];
        selection = nil;
        
        selected = [[filesController selectedObjects] retain];
        if([selected count] == 1)
        {
            selection = [[selected objectAtIndex:0] retain];
        }
        else if([selected count] > 1)
        {
            for(MetaEdits* edit in selected)
            {
                [[NSNotificationCenter defaultCenter]
                        addObserver:self
                           selector:@selector(setAction:)
                               name:MZUndoActionNameNotification
                             object:[edit undoManager]];
                [[NSNotificationCenter defaultCenter]
                        addObserver:self
                           selector:@selector(madeAction:)
                               name:NSUndoManagerDidOpenUndoGroupNotification
                             object:[edit undoManager]];
                [[NSNotificationCenter defaultCenter]
                        addObserver:self
                           selector:@selector(madeAction:)
                               name:NSUndoManagerDidRedoChangeNotification
                             object:[edit undoManager]];
                [[NSNotificationCenter defaultCenter]
                        addObserver:self
                           selector:@selector(undidAction:)
                               name:NSUndoManagerDidUndoChangeNotification
                             object:[edit undoManager]];
            }
            multipleUndoManager = [[NSUndoManager alloc] init];
        }
    } else
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

#pragma mark - implementation

-(NSUndoManager *)undoManager
{
    if(multipleUndoManager)
        return multipleUndoManager;
    if(selection)
        return [selection undoManager];
    return nil;
}

- (void)setAction:(NSNotification *)note
{
    NSString* name = [[note userInfo] objectForKey:MZUndoActionNameKey];
    [multipleUndoManager setActionName:name];
}

- (void)madeAction:(NSNotification *)note
{
    NSUndoManager* other = [note object];
    [multipleUndoManager registerUndoWithTarget:other selector:@selector(undo) object:nil];
}

- (void)undidAction:(NSNotification *)note
{
    NSUndoManager* other = [note object];
    [multipleUndoManager registerUndoWithTarget:other selector:@selector(redo) object:nil];
}

@end
