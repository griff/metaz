//
//  MZDynamicObject.m
//  MetaZ
//
//  Created by Brian Olsen on 04/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "MZDynamicObject.h"
#import "MZDataMethod.h"

@implementation MZDynamicObject

-(id)init {
    self = [super init];
    methods = [[NSMutableDictionary alloc] init];
    return self;
}

-(void)dealloc {
    [methods release];
    [super dealloc];
}

-(void)addMethodSetterForKey:(NSString *)aKey ofType:(NSUInteger)aType withObjCType:(const char*)aObjcType {
    MZDataMethod* method = [MZDataMethod methodSetterForKey:aKey ofType:aType withObjCType:aObjcType];
    [methods setObject:method forKey:NSStringFromSelector([method selector])];
}

-(void)addMethodGetterForKey:(NSString *)aKey ofType:(NSUInteger)aType withObjCType:(const char*)aObjcType {
    MZDataMethod* method = [MZDataMethod methodGetterForKey:aKey ofType:aType withObjCType:aObjcType];
    [methods setObject:method forKey:NSStringFromSelector([method selector])];
}

-(void)addMethodWithSelector:(SEL)aSelector andSignature:(NSMethodSignature *)aSignature forKey:(NSString *)aKey ofType:(NSUInteger)aType {
    MZDataMethod* method = [MZDataMethod methodWithSelector:aSelector andSignature:aSignature forKey:aKey ofType:aType];
    [methods setObject:method forKey:NSStringFromSelector(aSelector)];
}

-(void)handleDataForKey:(NSString *)aKey ofType:(NSUInteger)aType forInvocation:(NSInvocation *)anInvocation {
    [self doesNotRecognizeSelector:_cmd];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ( [super respondsToSelector:aSelector] )
        return YES;
    id ret = [methods objectForKey:NSStringFromSelector(aSelector)];
    return ret != nil;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *ret = [super methodSignatureForSelector:aSelector];
    if(ret == nil)
    {
        MZDataMethod* method = [methods objectForKey:NSStringFromSelector(aSelector)];
        if(method != nil)
            ret = [method signature];
    }
    return ret;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    MZDataMethod* method = [methods objectForKey:NSStringFromSelector([anInvocation selector])];
    if(method != nil)
        [self handleDataForKey:[method key] ofType:[method type] forInvocation:anInvocation];
    else
        [super forwardInvocation:anInvocation];
}

/*
 These don't work for methods that return something else than id
 
- (id)valueForUndefinedKey:(NSString *)aKey {
    MZDataMethod* method = [methods objectForKey:aKey];
    if(method != nil)
        return [self performSelector:[method selector]];
    return [super valueForUndefinedKey:aKey];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSString* setterKey = [MZDataMethod setterForKey:key];
    MZDataMethod* method = [methods objectForKey:setterKey];
    if(method != nil)
        [self performSelector:[method selector] withObject:value];
    else
        [super setValue:value forUndefinedKey:key];
}
*/

@end
