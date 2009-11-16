//
//  NSObject-ProtectedKeyValue.h
//  MetaZ
//
//  Created by Brian Olsen on 16/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSObject (ProtectedKeyValue)

- (id)protectedValueForKey:(NSString *)key;
- (id)protectedValueForKeyPath:(NSString *)keyPath;

@end
