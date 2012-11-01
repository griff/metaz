//
//  MetaEdits.h
//  MetaZ
//
//  Created by Brian Olsen on 24/08/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/MetaData.h>
#import <MetaZKit/MZDynamicObject.h>
#import <MetaZKit/MetaEditsUndoManager.h>

#define MZMetaEditsDataType @"MZMetaEditsDataType"

@interface MetaEdits : MZDynamicObject <MetaData, NSCopying, NSCoding> {
    NSMutableDictionary* changes;
    NSObject<MetaData>* provider;
    NSObject<TagData>* pure;
    MetaEditsUndoManager* undoManager;
}
@property(readonly) MetaEditsUndoManager* undoManager;
@property(readonly) NSDictionary* changes;
@property(readonly) NSObject<MetaData>* provider;
@property(readonly) id<TagData> pure;

+ (id)editsWithProvider:(id<MetaData>)aProvider;
- (id)initWithProvider:(id<MetaData>)aProvider;

- (NSString *)loadedFileName;
- (NSString *)savedFileName;
- (NSString *)savedTempFileName;

- (BOOL)changed;
- (NSArray *)providedTags;

- (id)getterValueForKey:(NSString *)aKey;
- (BOOL)getterChangedForKey:(NSString *)aKey;
- (void)setterChanged:(BOOL)aValue forKey:(NSString *)aKey;
- (void)setterValue:(id)aValue forKey:(NSString *)aKey;

@end
