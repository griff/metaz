//
//  NSArray-Mapping.h
//  MetaZ
//
//  Created by Brian Olsen on 25/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSArray (Mapping)

- (NSArray *)arrayByPerformingSelector:(SEL)aSelector;
- (NSArray *)arrayByPerformingSelector:(SEL)aSelector withObject:(id)anObject;
- (NSArray *)arrayByPerformingKey:(NSString *)key;
- (NSArray *)arrayByPerformingKeyPath:(NSString *)keyPath;
- (NSArray *)arrayByPerformingProtectedKey:(NSString *)key;
- (NSArray *)arrayByPerformingProtectedKeyPath:(NSString *)keyPath;

@end
