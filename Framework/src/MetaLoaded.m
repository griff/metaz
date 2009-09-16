//
//  MetaLoaded.m
//  MetaZ
//
//  Created by Brian Olsen on 25/08/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "MetaLoaded.h"
//#import "MetaEdits.h"

@implementation MetaLoaded
@synthesize loadedFileName;

-(id)initWithKeys:(NSArray *)keys
{
    self = [super init];
    tags = nil;
    loadedFileName = nil;
    for(NSString *key in keys)
        [self addMethodGetterForKey:key ofType:1 withObjCType:@encode(id)];
    return self;
}

-(id)initWithFilename:(NSString *)aFileName dictionary:(NSDictionary *)dict {
    self = [self initWithKeys:[dict allKeys]];
    loadedFileName = [aFileName retain];
    tags = [[NSDictionary alloc]initWithDictionary:dict];
    return self;
}

- (void)dealloc {
    if(tags) [tags release];
    [loadedFileName release];
    [super dealloc];
}

-(void)handleDataForKey:(NSString *)aKey ofType:(NSUInteger)aType forInvocation:(NSInvocation *)anInvocation {
    id ret = [self getterValueForKey:aKey];
    [anInvocation setReturnValue:&ret];
}

-(id)getterValueForKey:(NSString *)aKey {
    id ret = [tags objectForKey:aKey];
    if(ret == [NSNull null])
        return nil;
    return ret;
}

-(NSArray *)providedKeys {
    return [tags allKeys];
}

- (id)valueForUndefinedKey:(NSString *)key {
    if([self respondsToSelector:NSSelectorFromString(key)])
    {
        return [self getterValueForKey:key];
    }
    return [super valueForUndefinedKey:key];
}

#pragma mark - NSCoding implementation

- (id)initWithCoder:(NSCoder *)decoder
{
    NSDictionary* dict;
    NSString* loadedFile;
    if([decoder allowsKeyedCoding])
    {
        loadedFile = [decoder decodeObjectForKey:@"loadedFileName"];
        dict = [decoder decodeObjectForKey:@"tags"];
    }
    else
    {
        loadedFile = [decoder decodeObject];
        dict = [decoder decodeObject];
    }
    return [self initWithFilename:loadedFile dictionary:dict];
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    if([encoder allowsKeyedCoding])
    {
        [encoder encodeObject:loadedFileName forKey:@"loadedFileName"];
        [encoder encodeObject:tags forKey:@"tags"];
    }
    else
    {
        [encoder encodeObject:loadedFileName];
        [encoder encodeObject:tags];
    }
}

#pragma mark - NSCopying implementation

- (id)copyWithZone:(NSZone *)zone
{
    return [[MetaLoaded alloc] initWithFilename:loadedFileName dictionary:tags];
}

/*
- (id)valueForUndefinedKey:(NSString *)key {
    id ret = [tags objectForKey:key];
    if(ret == nil)
        return [super valueForUndefinedKey:key];
    return ret;
}
*/

@end
