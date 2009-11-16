//
//  NSUserDefaults-KeyPath.m
//  MetaZ
//
//  Created by Brian Olsen on 17/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "NSUserDefaults+KeyPath.h"

@interface NSUserDefaults (MZKeyPathsPrivate)

- (id)valueForComponents:(NSArray *)components;
- (void)setValue:(id)value forComponents:(NSArray *)components;

@end


@implementation NSUserDefaults (MZKeyPaths)

- (id)valueForComponents:(NSArray *)components
{
    NSInteger len = [components count];
    NSString* name = [components objectAtIndex:0];
    NSDictionary* dict = [self dictionaryForKey:name];
    for(NSInteger i=1; i<len-1 && [dict isKindOfClass:[NSDictionary class]]; i++)
    {
        name = [components objectAtIndex:i];
        dict = [dict objectForKey:name];
    }
    if([dict isKindOfClass:[NSDictionary class]])
        return [dict objectForKey:[components lastObject]];
    return nil;
}

- (void)setValue:(id)value forComponents:(NSArray *)components
{
    NSInteger len = [components count];
    NSString* name = [components objectAtIndex:0];
    NSMutableDictionary* dict;
    NSMutableDictionary* root = dict = [NSMutableDictionary dictionaryWithDictionary:[self dictionaryForKey:name]];
    for(NSInteger i=1; i<len-1; i++)
    {
        name = [components objectAtIndex:i];
        NSMutableDictionary* nextDict = [NSMutableDictionary dictionaryWithDictionary:[dict objectForKey:name]];
        [dict setObject:nextDict forKey:name];
        dict = nextDict;
    }
    [dict setObject:value forKey:[components lastObject]];
    [self setObject:root forKey:[components objectAtIndex:0]];
}

- (BOOL)boolForKeyPath:(NSString *)defaultName
{
    NSArray* components = [defaultName componentsSeparatedByString:@"."];
    NSInteger len = [components count];
    if(len == 1)
        return [self boolForKey:defaultName];
        
    id value = [self valueForComponents:components];
    if([value isKindOfClass:[NSNumber class]])
        return [value boolValue];
    return NO;
}

- (void)setBool:(BOOL)value forKeyPath:(NSString *)defaultName
{
    NSArray* components = [defaultName componentsSeparatedByString:@"."];
    NSInteger len = [components count];
    if(len == 1)
    {
        [self setBool:value forKey:defaultName];
        return;
    }
    [self setValue:[NSNumber numberWithBool:value] forComponents:components];
}

@end
