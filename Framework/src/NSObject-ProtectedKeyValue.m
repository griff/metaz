//
//  NSObject-ProtectedKeyValue.m
//  MetaZ
//
//  Created by Brian Olsen on 16/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "NSObject-ProtectedKeyValue.h"


@implementation NSObject (ProtectedKeyValue)

- (id)protectedValueForKey:(NSString *)key
{
    @try {
        return [self valueForKey:key];
    }
    @catch (NSException * e) {
        if(![[e name] isEqual:@"NSUnknownKeyException"])
            @throw;
    }
    return NSNotApplicableMarker;
}

- (id)protectedValueForKeyPath:(NSString *)keyPath
{
    @try {
        return [self valueForKeyPath:keyPath];
    }
    @catch (NSException * e) {
        if(![[e name] isEqual:@"NSUnknownKeyException"])
            @throw;
    }
    return NSNotApplicableMarker;
}

@end
