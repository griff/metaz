//
//  NSError+MZScriptError.m
//  MetaZ
//
//  Created by Brian Olsen on 05/11/12.
//  Copyright 2012 Maven-Group. All rights reserved.
//

#import "NSError+MZScriptError.h"


@implementation NSError (MZScriptError)

+ (id)errorWithAppleScriptError:(NSDictionary *)errDict
{
    return [[[self alloc] errorWithAppleScriptError:errDict] autorelease];
}

- (id)initWithAppleScriptError:(NSDictionary *)errDict
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithDictionary:errDict];
    NSInteger code = [[errDict objectForKey:NSAppleScriptErrorNumber] integerValue];
    NSString* msg = [errDict objectForKey:NSAppleScriptErrorMessage];
    
    if(msg)
        [dict setObject:msg forKey:NSLocalizedDescriptionKey];
    return [self initWithDomain:@"NSAppleScriptError" code:code userInfo:dict];
}

@end
