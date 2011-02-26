//
//  MetaLoaded.h
//  MetaZ
//
//  Created by Brian Olsen on 25/08/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <MetaZKit/MetaData.h>
#import <MetaZKit/MZGuessData.h>
#import <MetaZKit/MZDynamicObject.h>

@interface MetaLoaded : MZDynamicObject <MetaData, NSCopying> {
    NSDictionary* values;
    NSString* loadedFileName;
    MZGuessData* guesses;
    id owner;
}
@property(readonly) NSString* loadedFileName;
@property(readonly) id owner;

+ (id)metaWithOwner:(id)theOwner filename:(NSString *)aFileName dictionary:(NSDictionary *)dict;
- (id)initWithOwner:(id)theOwner filename:(NSString *)aFileName dictionary:(NSDictionary *)dict;

- (NSArray *)providedTags;

- (id)getterValueForKey:(NSString *)aKey;

@end
