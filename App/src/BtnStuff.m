//
//  BtnStuff.m
//  MetaZ
//
//  Created by Brian Olsen on 15/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "BtnStuff.h"


@implementation BtnStuff

-(id)initWithProxy:(id)aProxy
{
    proxy = [aProxy retain];
    return self;
}

-(void)dealloc
{
    [proxy release];
    [super dealloc];
}

- (Class)class
{
    return [proxy class];
}

- (Class)superclass
{
    return [proxy superclass];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol
{
    return [proxy conformsToProtocol:aProtocol];
}

- (NSString *)description
{
    return [proxy description];
}

- (NSUInteger)hash
{
    return [proxy hash];
}

/*
- (BOOL)isEqual:(id)anObject
{
    return [proxy isEqual:anObject];
}
*/

- (BOOL)isKindOfClass:(Class)aClass
{
    return [proxy isKindOfClass:aClass];
}

- (BOOL)isMemberOfClass:(Class)aClass
{
    return [proxy isMemberOfClass:aClass];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    NSLog(@"respondsToSelector: '%@'", NSStringFromSelector(aSelector));
    return [proxy respondsToSelector:aSelector];
}

- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder
{
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    return [proxy methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    [anInvocation setTarget:proxy];
    NSLog(@"Invoke: '%@'", NSStringFromSelector([anInvocation selector]));
    [anInvocation invoke];
    return;
}

@end
