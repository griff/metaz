//
//  MZPresets.h
//  MetaZ
//
//  Created by Brian Olsen on 25/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/MetaZKit.h>

MZKIT_EXTERN NSString* const MZPresetAddedNotification;
MZKIT_EXTERN NSString* const MZPresetRemovedNotification;
MZKIT_EXTERN NSString* const MZPresetRenamedNotification;

MZKIT_EXTERN NSString* const MZPresetKey;
MZKIT_EXTERN NSString* const MZPresetOldNameKey;
MZKIT_EXTERN NSString* const MZPresetNewNameKey;

@interface MZPreset : NSObject <NSCoding>
{
    NSString* name;
    NSDictionary* values;
}

+ (id)presetWithName:(NSString *)name values:(NSDictionary *)values;
- (id)initWithName:(NSString *)name values:(NSDictionary *)values;

@property (retain,nonatomic) NSString* name;
@property (readonly, retain) NSDictionary* values;

- (void)applyToObject:(id)object withPrefix:(NSString *)prefix;

@end


@interface MZPresets : NSObject {
    NSString* fileName;
    NSMutableArray* presets;
}

+ (MZPresets *)sharedPresets;

@property (readonly,retain) NSArray* presets;

- (void)removeObjectFromPresetsAtIndex:(NSUInteger)index;
- (void)insertObject:(MZPreset *)aPreset inPresetsAtIndex:(NSUInteger)index;

- (void)addObject:(MZPreset *)preset;
- (NSArray *)loadFromMetaXWithError:(NSError **)error;
- (BOOL)loadWithError:(NSError **)error;
- (BOOL)saveWithError:(NSError **)error;

@end
