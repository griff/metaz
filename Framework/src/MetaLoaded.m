//
//  MetaLoaded.m
//  MetaZ
//
//  Created by Brian Olsen on 25/08/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <MetaZKit/MetaLoaded.h>
#import <MetaZKit/MZPluginController.h>
//#import <MetaZKit/MetaEdits.h>

@implementation MetaLoaded
@synthesize loadedFileName;
@synthesize owner;

+ (id)metaWithOwner:(id)theOwner filename:(NSString *)aFileName dictionary:(NSDictionary *)dict;
{
    return [[[self alloc] initWithOwner:theOwner filename:aFileName dictionary:dict] autorelease];
}

-(id)initWithOwner:(id)theOwner filename:(NSString *)aFileName dictionary:(NSDictionary *)dict {
    self = [super init];
    if(self)
    {
        owner = [theOwner retain];
        loadedFileName = [aFileName retain];
        tags = [[NSDictionary alloc]initWithDictionary:dict];
        for(NSString *key in [dict allKeys])
            [self addMethodGetterForKey:key ofType:1 withObjCType:@encode(id)];
    }
    return self;
}

- (void)dealloc {
    [tags release];
    [loadedFileName release];
    [owner release];
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
    id theOwner;
    NSString * ownerId;
    if([decoder allowsKeyedCoding])
    {
        loadedFile = [decoder decodeObjectForKey:@"loadedFileName"];
        dict = [decoder decodeObjectForKey:@"tags"];
        theOwner = [decoder decodeObjectForKey:@"owner"];
        if(!theOwner)
            ownerId = [decoder decodeObjectForKey:@"ownerId"];
    }
    else
    {
        loadedFile = [decoder decodeObject];
        dict = [decoder decodeObject];
        theOwner = [decoder decodeObject];
        ownerId = [decoder decodeObject];
    }
    if(!theOwner)
    {
        theOwner = [[MZPluginController sharedInstance]
            dataProviderWithIdentifier:ownerId];
    }
    return [self initWithOwner:theOwner filename:loadedFile dictionary:dict];
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    if([encoder allowsKeyedCoding])
    {
        [encoder encodeObject:loadedFileName forKey:@"loadedFileName"];
        [encoder encodeObject:tags forKey:@"tags"];
        [encoder encodeConditionalObject:owner forKey:@"owner"];
        [encoder encodeObject:[owner identifier] forKey:@"ownerId"];
    }
    else
    {
        [encoder encodeObject:loadedFileName];
        [encoder encodeObject:tags];
        [encoder encodeConditionalObject:owner];
        [encoder encodeObject:[owner identifier]];
    }
}

#pragma mark - NSCopying implementation

- (id)copyWithZone:(NSZone *)zone
{
    //return [[MetaLoaded alloc] initWithFilename:loadedFileName dictionary:tags];
    return [self retain];
}

- (id<MetaData>)queueCopy
{
    return [self copy];
}

@end
