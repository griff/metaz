//
//  MetaLoaded.m
//  MetaZ
//
//  Created by Brian Olsen on 25/08/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "MetaLoaded.h"
#import "MetaEdits.h"

@implementation MetaLoaded
@synthesize loadedFileName;

-(id)initWithKeys:(NSArray *)keys
{
    self = [super init];
    for(NSString *key in keys)
        [self addMethodGetterForKey:key ofType:1 withObjCType:@encode(id)];
    return self;
}

-(id)initWithDictionary:(NSDictionary *)dict {
    self = [self initWithKeys:[dict allKeys]];
    loadedFileName = [dict objectForKey:MZFileNameTag];
    tags = [[NSDictionary alloc]initWithDictionary:dict];
    return self;
}

- (void)dealloc {
    if(tags) [tags release];
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

/*
- (id)valueForUndefinedKey:(NSString *)key {
    id ret = [tags objectForKey:key];
    if(ret == nil)
        return [super valueForUndefinedKey:key];
    return ret;
}
*/

@end
