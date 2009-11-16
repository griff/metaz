//
//  ToolTipLabel.h
//  MetaZ
//
//  Created by Brian Olsen on 16/11/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ToolTipLabel : NSTextField
{
    NSString* text;
    BOOL showsToolTip;
}

- (void)showToolTip:(NSString *)toolTip;
- (void)clearToolTip;

@end
