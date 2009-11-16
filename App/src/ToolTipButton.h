//
//  ToolTipButton.h
//  MetaZ
//
//  Created by Brian Olsen on 16/11/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ToolTipLabel.h"

@interface ToolTipButton : NSButton
{
    ToolTipLabel* label;
    NSString* tip;
    NSImage* orgImage;
}
@property (nonatomic, retain) IBOutlet ToolTipLabel* label;
@property (nonatomic, retain) NSString* tip;

@end
