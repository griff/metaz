//
//  MetaLoaded.h
//  MetaZ
//
//  Created by Brian Olsen on 25/08/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MetaData.h"
#import "MZDynamicObject.h"

@interface MetaLoaded : MZDynamicObject <MetaData, NSCopying> {
    NSDictionary* tags;
    NSString* loadedFileName;
}
@property(readonly) NSString* loadedFileName;

+ (id)metaWithFilename:(NSString *)aFileName dictionary:(NSDictionary *)dict;

- (id)initWithKeys:(NSArray *)keys;
- (id)initWithFilename:(NSString *)aFileName dictionary:(NSDictionary *)dict;

- (NSArray *)providedKeys;

- (id)getterValueForKey:(NSString *)aKey;

@end
