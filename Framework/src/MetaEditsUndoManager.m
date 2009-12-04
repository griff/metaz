//
//  MetaEditsUndoManager.m
//  MetaZ
//
//  Created by Brian Olsen on 18/11/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "MetaEditsUndoManager.h"


@implementation MetaEditsUndoManager

- (id)init
{
    self = [super init];
    if(self)
    {
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)setActionName:(NSString *)actionName
{
    [super setActionName:actionName];
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:actionName forKey:MZUndoActionNameKey];
    [[NSNotificationCenter defaultCenter]
        postNotificationName:MZUndoActionNameNotification object:self userInfo:userInfo];
}

@end
