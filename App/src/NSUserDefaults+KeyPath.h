//
//  NSUserDefaults-KeyPath.h
//  MetaZ
//
//  Created by Brian Olsen on 17/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSUserDefaults (MZKeyPaths)

- (BOOL)boolForKey:(NSString *)defaultName default:(BOOL)defaultValue;
- (double)doubleForKey:(NSString *)defaultName default:(double)defaultValue;
- (float)floatForKey:(NSString *)defaultName  default:(float)defaultValue;
- (NSInteger)integerForKey:(NSString *)defaultName default:(NSInteger)defaultValue;
- (id)objectForKey:(NSString *)defaultName default:(id)defaultValue;
- (NSData *)dataForKey:(NSString *)defaultName default:(NSData *)defaultValue;
- (NSDictionary *)dictionaryForKey:(NSString *)defaultName default:(NSDictionary *)defaultValue;
- (NSString *)stringForKey:(NSString *)defaultName default:(NSString *)defaultValue;
- (NSArray *)stringArrayForKey:(NSString *)defaultName default:(NSArray *)defaultValue;

- (BOOL)boolForKeyPath:(NSString *)defaultName;
- (double)doubleForKeyPath:(NSString *)defaultName;
- (float)floatForKeyPath:(NSString *)defaultName;
- (NSInteger)integerForKeyPath:(NSString *)defaultName;
- (id)objectForKeyPath:(NSString *)defaultName;
- (NSData *)dataForKeyPath:(NSString *)defaultName;
- (NSDictionary *)dictionaryForKeyPath:(NSString *)defaultName;
- (NSString *)stringForKeyPath:(NSString *)defaultName;
- (NSArray *)stringArrayForKeyPath:(NSString *)defaultName;

- (BOOL)boolForKeyPath:(NSString *)defaultName default:(BOOL)defaultValue;
- (double)doubleForKeyPath:(NSString *)defaultName default:(double)defaultValue;
- (float)floatForKeyPath:(NSString *)defaultName  default:(float)defaultValue;
- (NSInteger)integerForKeyPath:(NSString *)defaultName default:(NSInteger)defaultValue;
- (id)objectForKeyPath:(NSString *)defaultName default:(id)defaultValue;
- (NSData *)dataForKeyPath:(NSString *)defaultName default:(NSData *)defaultValue;
- (NSDictionary *)dictionaryForKeyPath:(NSString *)defaultName default:(NSDictionary *)defaultValue;
- (NSString *)stringForKeyPath:(NSString *)defaultName default:(NSString *)defaultValue;
- (NSArray *)stringArrayForKeyPath:(NSString *)defaultName default:(NSArray *)defaultValue;

- (void)setBool:(BOOL)value forKeyPath:(NSString *)defaultName;
- (void)setDouble:(double)value forKeyPath:(NSString *)defaultName;
- (void)setFloat:(float)value forKeyPath:(NSString *)defaultName;
- (void)setInteger:(NSInteger)value forKeyPath:(NSString *)defaultName;
- (void)setObject:(id)value forKeyPath:(NSString *)defaultName;

@end
