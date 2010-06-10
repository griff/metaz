//
//  MZTag.h
//  MetaZ
//
//  Created by Brian Olsen on 23/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

@interface MZTag : NSObject
{
    NSString* identifier;
}

+ (NSArray *)infoTags;
+ (NSArray *)videoTags;
+ (NSArray *)sortTags;
+ (NSArray *)advancedTags;
+ (NSArray *)chapterTags;
+ (NSArray *)allKnownTags;
+ (NSString *)localizedNameForKnownIdentifier:(NSString *)identifier;
+ (void)registerTag:(MZTag *)tag;
+ (MZTag *)tagForIdentifier:(NSString *)identifier;

+ (id)tagWithIdentifier:(NSString *)identifier;
- (id)initWithIdentifier:(NSString *)identifier;

@property(readonly) NSString *identifier;
@property(readonly) NSString *localizedName;
@property(readonly) NSCell *editorCell;
- (const char*)encoding;
- (id)convertValueToObject:(void*)buffer;
- (void)convertObject:(id)obj toValue:(void*)buffer;
- (id)nullConvertValueToObject:(void*)buffer;
- (void)nullConvertObject:(id)obj toValue:(void*)buffer;
- (id)convertObjectForRetrival:(id)obj;
- (id)convertObjectForStorage:(id)obj;
- (id)objectFromString:(NSString *)str;
- (NSString *)stringForObject:(id)str;

@end


@interface MZReadOnlyTag : MZTag {}

@end


@interface MZStringTag : MZTag {}

@end


@interface MZDateTag : MZTag {}

@end


@interface MZIntegerTag : MZTag {}

@end


@interface MZBoolTag : MZTag {}

@end

@interface MZEnumTag : MZTag {}

+ (id)tag;
- (int)nilValue;

@end

@interface MZTimeCodeTag : MZTag {}

@end

