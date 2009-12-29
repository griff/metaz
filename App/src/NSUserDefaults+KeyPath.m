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

- (BOOL)boolForKey:(NSString *)defaultName default:(BOOL)defaultValue
{
    if([self objectForKey:defaultName])
        return [self boolForKey:defaultName];
    return defaultValue;
}

- (double)doubleForKey:(NSString *)defaultName default:(double)defaultValue
{
    if([self objectForKey:defaultName])
        return [self doubleForKey:defaultName];
    return defaultValue;
}

- (float)floatForKey:(NSString *)defaultName  default:(float)defaultValue
{
    if([self objectForKey:defaultName])
        return [self floatForKey:defaultName];
    return defaultValue;
}

- (NSInteger)integerForKey:(NSString *)defaultName default:(NSInteger)defaultValue
{
    if([self objectForKey:defaultName])
        return [self integerForKey:defaultName];
    return defaultValue;
}

- (id)objectForKey:(NSString *)defaultName default:(id)defaultValue
{
    id ret = [self objectForKey:defaultName];
    if(ret)
        return ret;
    return defaultValue;
}

- (NSData *)dataForKey:(NSString *)defaultName default:(NSData *)defaultValue
{
    id ret = [self objectForKey:defaultName];
    if(ret && [ret isKindOfClass:[NSData class]])
        return ret;
    return defaultValue;
}

- (NSDictionary *)dictionaryForKey:(NSString *)defaultName default:(NSDictionary *)defaultValue
{
    id ret = [self objectForKey:defaultName];
    if(ret && [ret isKindOfClass:[NSDictionary class]])
        return ret;
    return defaultValue;
}

- (NSString *)stringForKey:(NSString *)defaultName default:(NSString *)defaultValue
{
    id ret = [self objectForKey:defaultName];
    if(ret && [ret isKindOfClass:[NSString class]])
        return ret;
    return defaultValue;
}

- (NSArray *)stringArrayForKey:(NSString *)defaultName default:(NSArray *)defaultValue
{
    id ret = [self objectForKey:defaultName];
    if(ret && [ret isKindOfClass:[NSArray class]])
        return ret;
    return defaultValue;
}



- (BOOL)boolForKeyPath:(NSString *)defaultName
{
    return [self boolForKeyPath:defaultName default:NO];
}

- (double)doubleForKeyPath:(NSString *)defaultName
{
    return [self doubleForKeyPath:defaultName default:0.0];
}

- (float)floatForKeyPath:(NSString *)defaultName
{
    return [self floatForKeyPath:defaultName default:0.0f];
}

- (NSInteger)integerForKeyPath:(NSString *)defaultName
{
    return [self integerForKeyPath:defaultName default:0];
}

- (id)objectForKeyPath:(NSString *)defaultName
{
    return [self objectForKeyPath:defaultName default:nil];
}

- (NSData *)dataForKeyPath:(NSString *)defaultName
{
    return [self dataForKeyPath:defaultName default:nil];
}

- (NSDictionary *)dictionaryForKeyPath:(NSString *)defaultName
{
    return [self dictionaryForKeyPath:defaultName default:nil];
}

- (NSString *)stringForKeyPath:(NSString *)defaultName
{
    return [self stringForKeyPath:defaultName default:nil];
}

- (NSArray *)stringArrayForKeyPath:(NSString *)defaultName
{
    return [self stringArrayForKeyPath:defaultName default:nil];
}



- (BOOL)boolForKeyPath:(NSString *)defaultName default:(BOOL)defaultValue
{
    NSArray* components = [defaultName componentsSeparatedByString:@"."];
    NSInteger len = [components count];
    if(len == 1)
        return [self boolForKey:defaultName default:defaultValue];
        
    id value = [self valueForComponents:components];
    if([value isKindOfClass:[NSNumber class]])
        return [value boolValue];
    return defaultValue;
}

- (double)doubleForKeyPath:(NSString *)defaultName default:(double)defaultValue
{
    NSArray* components = [defaultName componentsSeparatedByString:@"."];
    NSInteger len = [components count];
    if(len == 1)
        return [self doubleForKey:defaultName default:defaultValue];
        
    id value = [self valueForComponents:components];
    if([value isKindOfClass:[NSNumber class]])
        return [value doubleValue];
    return defaultValue;
}

- (float)floatForKeyPath:(NSString *)defaultName  default:(float)defaultValue
{
    NSArray* components = [defaultName componentsSeparatedByString:@"."];
    NSInteger len = [components count];
    if(len == 1)
        return [self floatForKey:defaultName default:defaultValue];
        
    id value = [self valueForComponents:components];
    if([value isKindOfClass:[NSNumber class]])
        return [value floatValue];
    return defaultValue;
}

- (NSInteger)integerForKeyPath:(NSString *)defaultName default:(NSInteger)defaultValue
{
    NSArray* components = [defaultName componentsSeparatedByString:@"."];
    NSInteger len = [components count];
    if(len == 1)
        return [self integerForKey:defaultName default:defaultValue];
        
    id value = [self valueForComponents:components];
    if([value isKindOfClass:[NSNumber class]])
        return [value integerValue];
    return defaultValue;
}

- (id)objectForKeyPath:(NSString *)defaultName default:(id)defaultValue
{
    NSArray* components = [defaultName componentsSeparatedByString:@"."];
    NSInteger len = [components count];
    if(len == 1)
        return [self objectForKey:defaultName default:defaultValue];
        
    id value = [self valueForComponents:components];
    if(value)
        return value;
    return defaultValue;
}

- (NSData *)dataForKeyPath:(NSString *)defaultName default:(NSData *)defaultValue
{
    NSArray* components = [defaultName componentsSeparatedByString:@"."];
    NSInteger len = [components count];
    if(len == 1)
        return [self dataForKey:defaultName default:defaultValue];
        
    id value = [self valueForComponents:components];
    if([value isKindOfClass:[NSData class]])
        return value;
    return defaultValue;
}

- (NSDictionary *)dictionaryForKeyPath:(NSString *)defaultName default:(NSDictionary *)defaultValue
{
    NSArray* components = [defaultName componentsSeparatedByString:@"."];
    NSInteger len = [components count];
    if(len == 1)
        return [self dictionaryForKey:defaultName default:defaultValue];
        
    id value = [self valueForComponents:components];
    if([value isKindOfClass:[NSDictionary class]])
        return value;
    return defaultValue;
}

- (NSString *)stringForKeyPath:(NSString *)defaultName default:(NSString *)defaultValue
{
    NSArray* components = [defaultName componentsSeparatedByString:@"."];
    NSInteger len = [components count];
    if(len == 1)
        return [self stringForKey:defaultName default:defaultValue];
        
    id value = [self valueForComponents:components];
    if([value isKindOfClass:[NSString class]])
        return value;
    return defaultValue;
}

- (NSArray *)stringArrayForKeyPath:(NSString *)defaultName default:(NSArray *)defaultValue
{
    NSArray* components = [defaultName componentsSeparatedByString:@"."];
    NSInteger len = [components count];
    if(len == 1)
        return [self stringArrayForKey:defaultName default:defaultValue];
        
    id value = [self valueForComponents:components];
    if([value isKindOfClass:[NSArray class]])
        return value;
    return defaultValue;
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

- (void)setDouble:(double)value forKeyPath:(NSString *)defaultName
{
    NSArray* components = [defaultName componentsSeparatedByString:@"."];
    NSInteger len = [components count];
    if(len == 1)
    {
        [self setDouble:value forKey:defaultName];
        return;
    }
    [self setValue:[NSNumber numberWithDouble:value] forComponents:components];
}

- (void)setFloat:(float)value forKeyPath:(NSString *)defaultName
{
    NSArray* components = [defaultName componentsSeparatedByString:@"."];
    NSInteger len = [components count];
    if(len == 1)
    {
        [self setFloat:value forKey:defaultName];
        return;
    }
    [self setValue:[NSNumber numberWithFloat:value] forComponents:components];
}

- (void)setInteger:(NSInteger)value forKeyPath:(NSString *)defaultName
{
    NSArray* components = [defaultName componentsSeparatedByString:@"."];
    NSInteger len = [components count];
    if(len == 1)
    {
        [self setInteger:value forKey:defaultName];
        return;
    }
    [self setValue:[NSNumber numberWithInteger:value] forComponents:components];
}

- (void)setObject:(id)value forKeyPath:(NSString *)defaultName
{
    NSArray* components = [defaultName componentsSeparatedByString:@"."];
    NSInteger len = [components count];
    if(len == 1)
    {
        [self setObject:value forKey:defaultName];
        return;
    }
    [self setValue:value forComponents:components];
}

@end
