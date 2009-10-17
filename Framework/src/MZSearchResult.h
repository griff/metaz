//
//  MZSearchResult.h
//  MetaZ
//
//  Created by Brian Olsen on 13/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <MetaZKit/TagData.h>
#import <MetaZKit/MZDynamicObject.h>

@interface MZSearchResult : MZDynamicObject <TagData>
{
    NSDictionary* values;
    id owner;
}
@property(readonly) id owner;
@property(readonly) NSImage* icon;

+ (id)resultWithOwner:(id)theOwner dictionary:(NSDictionary *)dict;
- (id)initWithOwner:(id)theOwner dictionary:(NSDictionary *)dict;

- (BOOL)hasChapters;
- (NSString *)searchResultTitle;
- (id)getterValueForKey:(NSString *)aKey;

- (NSMenu *)menu;

@end
