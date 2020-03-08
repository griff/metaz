//
//  FilesArrayController.m
//  MetaZ
//
//  Created by Brian Olsen on 08/11/12.
//  Copyright 2012 Maven-Group. All rights reserved.
//

#import "FilesArrayController.h"


@implementation FilesArrayController

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if(self)
    {
        editors = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithContent:(id)content
{
    self = [super initWithContent:content];
    if(self)
    {
        editors = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [editors release];
    [super dealloc];
}

- (void)registerUndoName:(NSUndoManager *)manager
{
    [manager setActionName:NSLocalizedString(@"Apply Search", @"Apply search undo name")];
    [manager registerUndoWithTarget:self 
                           selector:@selector(registerUndoName:)
                             object:manager];
}

- (void)registerEditor:(id<MZApplyEditor>)editor
{
    [editors addObject:editor];
}

- (void)unregisterEditor:(id<MZApplyEditor>)editor
{
    [editors removeObject:editor];
}

- (BOOL)canApply:(id)source;
{
    for(NSString* key in [source allKeys])
    {
        id value = [source objectForKey:key];
        if([value isKindOfClass:[RemoteData class]])
        {
            if(![value isLoaded])
                return NO;
        }
    }

    for(id<MZApplyEditor> editor in editors)
    {
        if(![editor canApply:source])
            return NO;
    }
    return YES;
}


- (void)apply:(id)source;
{
    if(![self canApply:source])
        return;
    
    NSArray* edits = [self selectedObjects];
    for(MetaEdits* edit in edits)
    {
        [self registerUndoName:edit.undoManager];
    }
    
    for(MetaEdits* edit in edits)
    {
        for(id<MZApplyEditor> editor in editors)
        {
            [editor applyData:source toEdit:edit];
        }
        
        NSArray* providedTags = [edit providedTags];
        for(MZTag* tag in providedTags)
        {
            if(![edit getterChangedForKey:[tag identifier]])
            {
                id value = [source objectForKey:[tag identifier]];
                if([value isKindOfClass:[RemoteData class]])
                    value = [value data];
                if([value isKindOfClass:[NSArray class]] &&
                   [value count] == 0)
                {
                    continue;
                }
                if(value)
                    [edit setterValue:value forKey:[tag identifier]];
            }
        }
        [self registerUndoName:edit.undoManager];
    }
}

@end
