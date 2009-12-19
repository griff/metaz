//
//  NSInvocation-Wrapping.m
//  MetaZ
//
//  Created by Brian Olsen on 03/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "NSInvocation+Wrapping.h"
#import <MetaZKit/GTMLogger.h>


@implementation NSInvocation (Wrapping)

- (void)setReturnObject:(id)value
{
    const char* methodReturnType = [[self methodSignature] methodReturnType];
    if(strcmp(methodReturnType, @encode(id)) == 0)
        [self setReturnValue:&value];
    else if(strcmp(methodReturnType, @encode(int)) == 0)
    {
        int ret = [value intValue];
        [self setReturnValue:&ret];
    }
    else if(strcmp(methodReturnType, @encode(char)) == 0)
    {
        char ret = [value charValue];
        [self setReturnValue:&ret];
    }
    else if(strcmp(methodReturnType, @encode(NSInteger)) == 0)
    {
        NSInteger ret = [value integerValue];
        [self setReturnValue:&ret];
    }
    else if(strcmp(methodReturnType, @encode(BOOL)) == 0)
    {
        BOOL ret = [value boolValue];
        [self setReturnValue:&ret];
    }
    else
    {
        MZLoggerError(@"Invalid type");
        [NSException raise:@"NSInvocationTypeConversion" format:@"Bad type '%s'", methodReturnType];
    }
}

- (id)returnObject
{
    const char* methodReturnType = [[self methodSignature] methodReturnType];
    if(strcmp(methodReturnType, @encode(id)) == 0)
    {
        id ret;
        [self getReturnValue:&ret];
        return ret;//[[ret retain] autorelease];
    }
    else if(strcmp(methodReturnType, @encode(int)) == 0)
    {
        int ret;
        [self getReturnValue:&ret];
        return [NSNumber numberWithInt:ret];
    }
    else if(strcmp(methodReturnType, @encode(char)) == 0)
    {
        char ret;
        [self getReturnValue:&ret];
        return [NSNumber numberWithChar:ret];
    }
    else if(strcmp(methodReturnType, @encode(NSInteger)) == 0)
    {
        NSInteger ret;
        [self getReturnValue:&ret];
        return [NSNumber numberWithInteger:ret];
    }
    else if(strcmp(methodReturnType, @encode(BOOL)) == 0)
    {
        BOOL ret;
        [self getReturnValue:&ret];
        return [NSNumber numberWithBool:ret];
    }
    else
    {
        MZLoggerError(@"Invalid type");
        [NSException raise:@"NSInvocationTypeConversion" format:@"Bad type '%s'", methodReturnType];
    }
    return nil;
}

- (void)setArgumentObject:(id)argument atIndex:(NSInteger)idx
{
    const char* methodReturnType = [[self methodSignature] getArgumentTypeAtIndex:idx];
    if(strcmp(methodReturnType, @encode(id)) == 0)
        [self setArgument:&argument atIndex:idx];
    else if(strcmp(methodReturnType, @encode(int)) == 0)
    {
        int ret = [argument intValue];
        [self setArgument:&ret atIndex:idx];
    }
    else if(strcmp(methodReturnType, @encode(char)) == 0)
    {
        char ret = [argument charValue];
        [self setArgument:&ret atIndex:idx];
    }
    else if(strcmp(methodReturnType, @encode(NSInteger)) == 0)
    {
        NSInteger ret = [argument integerValue];
        [self setArgument:&ret atIndex:idx];
    }
    else if(strcmp(methodReturnType, @encode(BOOL)) == 0)
    {
        BOOL ret = [argument boolValue];
        [self setArgument:&ret atIndex:idx];
    }
    else
    {
        MZLoggerError(@"Invalid type");
        [NSException raise:@"NSInvocationTypeConversion" format:@"Bad type '%s'", methodReturnType];
    }
}

- (id)argumentObjectAtIndex:(NSInteger)idx
{
    const char* methodReturnType = [[self methodSignature] getArgumentTypeAtIndex:idx];
    if(strcmp(methodReturnType, @encode(id)) == 0)
    {
        id ret;
        [self getArgument:&ret atIndex:idx];
        return [[ret retain] autorelease];
    }
    else if(strcmp(methodReturnType, @encode(int)) == 0)
    {
        int ret;
        [self getArgument:&ret atIndex:idx];
        return [NSNumber numberWithInt:ret];
    }
    else if(strcmp(methodReturnType, @encode(char)) == 0)
    {
        char ret;
        [self getArgument:&ret atIndex:idx];
        return [NSNumber numberWithChar:ret];
    }
    else if(strcmp(methodReturnType, @encode(NSInteger)) == 0)
    {
        NSInteger ret;
        [self getArgument:&ret atIndex:idx];
        return [NSNumber numberWithInteger:ret];
    }
    else if(strcmp(methodReturnType, @encode(BOOL)) == 0)
    {
        BOOL ret;
        [self getArgument:&ret atIndex:idx];
        return [NSNumber numberWithBool:ret];
    }
    else
    {
        MZLoggerError(@"Invalid type");
        [NSException raise:@"NSInvocationTypeConversion" format:@"Bad type '%s'", methodReturnType];
    }
    return nil;
}

@end
