//
//  MetaEdits.h
//  MetaZ
//
//  Created by Brian Olsen on 24/08/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MetaLoaded.h"
#import "MetaData.h"


@interface MetaEdits : MetaLoaded {
    id<MetaData> provider;
    //NSMutableDictionary* lastCache;
    NSUndoManager* undoManager;
    NSUndoManager* multiUndoManager;
}
@property(readonly) NSUndoManager* undoManager;
@property(retain)   NSUndoManager* multiUndoManager;

-(id)initWithProvider:(id<MetaData>)aProvider;

-(NSUndoManager *)undoManager;
-(NSString *)loadedFileName;

-(BOOL)changed;

-(BOOL)getterChangedForKey:(NSString *)aKey;
-(void)setterChanged:(BOOL)aValue forKey:(NSString *)aKey;
-(void)setterValue:(id)aValue forKey:(NSString *)aKey;

@end
