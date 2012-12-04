//
//  MZApplyEditor.h
//  MetaZ
//
//  Created by Brian Olsen on 14/11/12.
//  Copyright 2012 Maven-Group. All rights reserved.
//

#import <MetaZKit/MetaEdits.h>

@protocol MZApplyEditor

- (BOOL)canApply:(id)data;
- (void)applyData:(id)data toEdit:(MetaEdits *)edit;

@end


@protocol MZApplyController

- (void)registerEditor:(id<MZApplyEditor>)editor;
- (void)unregisterEditor:(id<MZApplyEditor>)editor;

@end
