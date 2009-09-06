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

@interface MetaLoaded : MZDynamicObject <MetaData> {
    NSDictionary* tags;
    NSString* loadedFileName;
}
@property(readonly) NSString* loadedFileName;

-(id)initWithKeys:(NSArray *)keys;
-(id)initWithDictionary:(NSDictionary *)dict;

-(NSArray *)providedKeys;

-(id)getterValueForKey:(NSString *)aKey;

@end
