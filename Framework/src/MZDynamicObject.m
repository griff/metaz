//
//  MZDynamicObject.m
//  MetaZ
//
//  Created by Brian Olsen on 04/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <MetaZKit/MZDynamicObject.h>
#import <MetaZKit/MZMethodData.h>

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
    MZMethodData* method = [MZMethodData methodSetterForKey:aKey ofType:aType withObjCType:aObjcType];
    [methods setObject:method forKey:NSStringFromSelector([method selector])];
}

-(void)addMethodSetterForKey:(NSString *)aKey withRealKey:(NSString *)aRealKey ofType:(NSUInteger)aType withObjCType:(const char*)aObjcType {
    MZMethodData* method = [MZMethodData methodSetterForKey:aKey withRealKey:aRealKey ofType:aType withObjCType:aObjcType];
    [methods setObject:method forKey:NSStringFromSelector([method selector])];
}

-(void)addMethodGetterForKey:(NSString *)aKey ofType:(NSUInteger)aType withObjCType:(const char*)aObjcType {
    MZMethodData* method = [MZMethodData methodGetterForKey:aKey ofType:aType withObjCType:aObjcType];
    [methods setObject:method forKey:NSStringFromSelector([method selector])];
}

-(void)addMethodGetterForKey:(NSString *)aKey withRealKey:(NSString *)aRealKey ofType:(NSUInteger)aType withObjCType:(const char*)aObjcType {
    MZMethodData* method = [MZMethodData methodGetterForKey:aKey withRealKey:aRealKey ofType:aType withObjCType:aObjcType];
    [methods setObject:method forKey:NSStringFromSelector([method selector])];
}

-(void)addMethodWithSelector:(SEL)aSelector signature:(NSMethodSignature *)aSignature forKey:(NSString *)aKey ofType:(NSUInteger)aType {
    MZMethodData* method = [MZMethodData methodWithSelector:aSelector signature:aSignature forKey:aKey ofType:aType];
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
        MZMethodData* method = [methods objectForKey:NSStringFromSelector(aSelector)];
        if(method != nil)
            ret = [method signature];
    }
    return ret;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    MZMethodData* method = [methods objectForKey:NSStringFromSelector([anInvocation selector])];
    if(method != nil)
        [self handleDataForKey:[method key] ofType:[method type] forInvocation:anInvocation];
    else
        [super forwardInvocation:anInvocation];
}

/*
 These don't work for methods that return something else than id
*/
/*
- (id)valueForUndefinedKey:(NSString *)aKey {
    MZMethodData* method = [methods objectForKey:aKey];
    if(method != nil)
    {
        NSInvocation* inv = [NSInvocation invocationWithMethodSignature:[method signature]];
        [self handleDataForKey:[method key] ofType:[method type] forInvocation:inv];
        return [inv returnObject];
    }
    return [super valueForUndefinedKey:aKey];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSString* setterKey = [MZMethodData setterForKey:key];
    MZMethodData* method = [methods objectForKey:setterKey];
    if(method != nil)
    {
        NSInvocation* inv = [NSInvocation invocationWithMethodSignature:[method signature]];
        [inv setArgumentObject:value atIndex:0];
        [self handleDataForKey:[method key] ofType:[method type] forInvocation:inv];
    }
    else
        [super setValue:value forUndefinedKey:key];
}
*/

@end
