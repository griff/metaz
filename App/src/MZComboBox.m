//
//  MZComboBox.m
//  MetaZ
//
//  Created by Brian Olsen on 08/11/12.
//  Copyright 2012 Maven-Group. All rights reserved.
//

#import "MZComboBox.h"


@implementation MZComboBox

- (BOOL)abortEditing
{
    if([super abortEditing])
    {
        [[self window] makeFirstResponder:self];
        return YES;
    }
    return NO;
}

@end
