//
//  NSInvocation-Wrapping.m
//  MetaZ
//
//  Created by Brian Olsen on 03/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "NSInvocation-Wrapping.h"


@implementation NSInvocation (Wrapping)

- (void)setReturnObject:(id)value
{
    const char* methodReturnType = [[self methodSignature] methodReturnType];
    /*
    const char* idt = @encode(id);
    const char* intt = @encode(int);
    const char* chart = @encode(char);
    int r = strcmp(methodReturnType, @encode(id));
    */
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
    else
    {
        NSLog(@"Invalid type");
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
    else
    {
        NSLog(@"Invalid type");
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
    else
    {
        NSLog(@"Invalid type");
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
    else
    {
        NSLog(@"Invalid type");
        [NSException raise:@"NSInvocationTypeConversion" format:@"Bad type '%s'", methodReturnType];
    }
    return nil;
}

@end
