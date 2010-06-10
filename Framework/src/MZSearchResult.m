//
//  MZSearchResult.m
//  MetaZ
//
//  Created by Brian Olsen on 13/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <MetaZKit/MZSearchResult.h>
#import <MetaZKit/MZPluginController.h>
#import <MetaZKit/MZTag.h>


@implementation MZSearchResult

#pragma mark - Contruction
+ (id)resultWithOwner:(id)theOwner dictionary:(NSDictionary *)dict
{
    return [[[self alloc] initWithOwner:theOwner dictionary:dict] autorelease];
}

-(id)initWithOwner:(id)theOwner dictionary:(NSDictionary *)dict
{
    self = [super init];
    if(self)
    {
        owner = [theOwner retain];
        values = [[NSDictionary alloc]initWithDictionary:dict];
        for(NSString* tagId in [dict allKeys])
        {
            MZTag* tag = [MZTag tagForIdentifier:tagId];
            [self addMethodGetterForKey:tagId ofType:1 withObjCType:[tag encoding]];
        }
    }
    return self;
}

- (void)dealloc
{
    [values release];
    [owner release];
    [super dealloc];
}

#pragma mark - methods
@synthesize owner;
@synthesize values;

- (NSImage* )icon
{
    return [owner icon];
}

- (NSMenu *)menu
{
    if([owner respondsToSelector:@selector(menuForResult:)])
        return [owner menuForResult:self];
    return nil;
}

- (id)hasChapters
{
    if([values objectForKey:MZChaptersTagIdent] != nil)
        return [NSNumber numberWithBool:YES];
    if([values objectForKey:MZChapterNamesTagIdent] != nil)
        return NSMultipleValuesMarker;
    return [NSNumber numberWithBool:NO];;
}

- (NSString *)searchResultTitle
{
    return [self valueForKey:@"title"];
}

-(id)getterValueForKey:(NSString *)aKey
{
    id ret = [values objectForKey:aKey];
    MZTag* tag = [MZTag tagForIdentifier:aKey];
    return [tag convertObjectForRetrival:ret];
}

#pragma mark - MZDynamicObject handling

-(void)handleDataForKey:(NSString *)aKey ofType:(NSUInteger)aType forInvocation:(NSInvocation *)anInvocation
{
    id ret = [self getterValueForKey:aKey];
    [anInvocation setReturnObject:ret];
}

-(id)handleDataForMethod:(NSString *)aMethod withKey:(NSString *)aKey ofType:(NSUInteger)aType
{
    return [self getterValueForKey:aKey];
}

#pragma mark - NSCoding implementation

- (id)initWithCoder:(NSCoder *)decoder
{
    NSDictionary* dict;
    id theOwner;
    NSString * ownerId;
    if([decoder allowsKeyedCoding])
    {
        dict = [decoder decodeObjectForKey:@"values"];
        theOwner = [decoder decodeObjectForKey:@"owner"];
        if(!theOwner)
            ownerId = [decoder decodeObjectForKey:@"ownerId"];
    }
    else
    {
        dict = [decoder decodeObject];
        theOwner = [decoder decodeObject];
        ownerId = [decoder decodeObject];
    }
    if(!theOwner)
    {
        theOwner = [[MZPluginController sharedInstance]
            searchProviderWithIdentifier:ownerId];
    }
    return [self initWithOwner:theOwner dictionary:dict];
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    if([encoder allowsKeyedCoding])
    {
        [encoder encodeObject:values forKey:@"values"];
        [encoder encodeConditionalObject:owner forKey:@"owner"];
        [encoder encodeObject:[owner identifier] forKey:@"ownerId"];
    }
    else
    {
        [encoder encodeObject:values];
        [encoder encodeConditionalObject:owner];
        [encoder encodeObject:[owner identifier]];
    }
}

#pragma mark - NSCopying implementation

- (id)copyWithZone:(NSZone *)zone
{
    return [self retain];
}

@end
