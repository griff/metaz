//
//  MZGuessData.h
//  MetaZ
//
//  Created by Brian Olsen on 31/10/10.
//  Copyright 2010 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MZGuessData : MZDynamicObject <TagData, NSCopying> {
    NSDictionary* values;
}

+ (id)guessWithOwner:(id)theOwner dictionary:(NSDictionary *)dict;
- (id)initWithOwner:(id)theOwner dictionary:(NSDictionary *)dict;

- (id)getterValueForKey:(NSString *)aKey;

@end
