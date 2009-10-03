//
//  MZTag.h
//  MetaZ
//
//  Created by Brian Olsen on 23/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

@interface MZTag : NSObject {
    NSString* identifier;
}

+ (NSArray *)infoTags;
+ (NSArray *)videoTags;
+ (NSArray *)sortTags;
+ (NSArray *)advancedTags;
+ (NSArray *)allKnownTags;
+ (NSString *)localizedNameForKnownIdentifier:(NSString *)identifier;
+ (void)registerTag:(MZTag *)tag;
+ (MZTag *)tagForIdentifier:(NSString *)identifier;

+ (id)tagWithIdentifier:(NSString *)identifier;

- (id)initWithIdentifier:(NSString *)identifier;

- (NSString *)identifier;
- (NSString *)localizedName; 
- (NSCell *)editorCell;
- (id)convertValueToObject:(void*)buffer;
- (void)convertObject:(id)obj toValue:(void*)buffer;
- (id)nullConvertValueToObject:(void*)buffer;
- (void)nullConvertObject:(id)obj toValue:(void*)buffer;

@end


@interface MZStringTag : MZTag {
}
//+ (id)tagWithIdentifier:(NSString *)identifier;

@end

@interface MZDateTag : MZTag {
}
//+ (id)tagWithIdentifier:(NSString *)identifier;

@end

@interface MZIntegerTag : MZTag {
}
//+ (id)tagWithIdentifier:(NSString *)identifier;

@end

@interface MZBoolTag : MZTag {
}
//+ (id)tagWithIdentifier:(NSString *)identifier;

@end
