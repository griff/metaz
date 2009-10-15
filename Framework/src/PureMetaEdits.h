//
//  PureMetaEdits.h
//  MetaZ
//
//  Created by Brian Olsen on 15/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/MetaEdits.h>
#import <MetaZKit/MZDynamicObject.h>

@interface PureMetaEdits : MZDynamicObject <TagData>
{
    MetaEdits* edits;
}

- (id)initWithEdits:(MetaEdits *)edits;

@end
