//
//  SearchProfile.h
//  MetaZ
//
//  Created by Brian Olsen on 15/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SearchProfile : NSObject {
    NSString* identifier;
    NSString* mainTag;
    NSArray* tags;
    id checkObj;
    NSString* checkPrefix;
}
+ (SearchProfile*)unknownTypeProfile;
+ (SearchProfile*)tvShowProfile;
+ (SearchProfile*)movieProfile;

+ (id)profileWithIdentifier:(NSString *)ident mainTag:(NSString *)main tag:(NSArray *)tags;
- (id)initWithIdentifier:(NSString *)ident mainTag:(NSString *)main tag:(NSArray *)tags;

@property(readonly) NSString* mainTag;
@property(readonly) NSArray* tags;
@property(readonly) NSString* identifier;

- (void)setCheckObject:(id)obj withPrefix:(NSString *)prefix;
- (void)switchItem:(NSMenuItem *)sender;
- (NSMutableDictionary *)searchTerms;

@end
