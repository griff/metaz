//
//  PureMetaEdits.m
//  MetaZ
//
//  Created by Brian Olsen on 15/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "PureMetaEdits.h"
#import <MetaZKit/MZTag.h>

@implementation PureMetaEdits

- (id)initWithEdits:(MetaEdits *)theEdits
{
    self = [super init];
    if(self)
    {
        edits = [theEdits retain];
        NSArray* tags = [edits providedTags];
        for(MZTag* tag in tags)
        {
            NSString* key = [tag identifier];
            NSObject<TagData>* pure = edits.provider.pure;
            [pure addObserver: self 
                   forKeyPath: key
                      options: NSKeyValueObservingOptionPrior
                      context: nil];
            [self addMethodGetterForKey:key ofType:1 withObjCType:[tag encoding]];
        }

    }
    return self;
}

- (void)dealloc
{
    NSObject<TagData>* pure = edits.provider.pure;
    NSArray* tags = [edits providedTags];
    for(MZTag *tag in tags)
        [pure removeObserver:self forKeyPath: [tag identifier]];
    [edits dealloc];
    [super dealloc];
}

- (id)owner
{
    return [edits owner];
}

-(id)getterValueForKey:(NSString *)aKey
{
    id ret = [edits.changes objectForKey:aKey];
    if(ret != nil) // Changed
    {
        MZTag* tag = [MZTag tagForIdentifier:aKey];
        return [tag convertObjectForRetrival:ret];
    }
    NSObject<TagData>* pure = edits.provider.pure;
    return [pure valueForKey:aKey];
}

-(void)handleDataForKey:(NSString *)aKey ofType:(NSUInteger)aType forInvocation:(NSInvocation *)anInvocation
{
    id ret = [self getterValueForKey:aKey];
    [anInvocation setReturnObject:ret];
}

/*
- (id)valueForUndefinedKey:(NSString *)key
{
    if([self respondsToSelector:NSSelectorFromString(key)])
        return [self getterValueForKey:key];
    return [super valueForUndefinedKey:key];
}
*/

#pragma mark - NSCoding implementation

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if(self)
    {
        edits = [[decoder decodeObjectForKey:@"edits"] retain];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:edits forKey:@"edits"];
}

#pragma mark - NSCopying implementation

- (id)copyWithZone:(NSZone *)zone
{
    return [self retain];
}

@end
