//
//  MZGuessData.h
//  MetaZ
//
//  Created by Brian Olsen on 31/10/10.
//  Copyright 2010 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/MZDynamicObject.h>

@interface MZGuessData : MZDynamicObject {
    NSDictionary* values;
}

+ (id)guessWithDictionary:(NSDictionary *)dict;
- (id)initWithDictionary:(NSDictionary *)dict;

- (id)getterValueForKey:(NSString *)aKey;

@end
