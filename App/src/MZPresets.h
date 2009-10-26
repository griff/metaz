//
//  MZPresets.h
//  MetaZ
//
//  Created by Brian Olsen on 25/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MZPreset : NSObject <NSCoding>
{
    NSString* name;
    NSDictionary* values;
}

- (id)initWithName:(NSString *)name values:(NSDictionary *)values;

@property (readonly, retain) NSString* name;
@property (readonly, retain) NSDictionary* values;

- (void)applyToObject:(id)object withPrefix:(NSString *)prefix;

@end


@interface MZPresets : NSObject {
    NSString* fileName;
    NSMutableArray* presets;
}

+ (MZPresets *)sharedPresets;

@property (readonly,retain) NSArray* presets;

- (NSArray *)loadFromMetaXWithError:(NSError **)error;
- (BOOL)loadWithError:(NSError **)error;
- (BOOL)saveWithError:(NSError **)error;

@end
