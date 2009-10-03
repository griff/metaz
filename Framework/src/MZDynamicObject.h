//
//  MZDynamicObject.h
//  MetaZ
//
//  Created by Brian Olsen on 04/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//
#import <MetaZKit/NSInvocation-Wrapping.h>

@interface MZDynamicObject : NSObject {
    NSMutableDictionary* methods;
}

-(id)init;

-(void)addMethodSetterForKey:(NSString *)aKey ofType:(NSUInteger)aType withObjCType:(const char*)aObjcType;
-(void)addMethodSetterForKey:(NSString *)aKey withRealKey:(NSString *)aRealKey ofType:(NSUInteger)aType withObjCType:(const char*)aObjcType;
-(void)addMethodGetterForKey:(NSString *)aKey ofType:(NSUInteger)aType withObjCType:(const char*)aObjcType;
-(void)addMethodGetterForKey:(NSString *)aKey withRealKey:(NSString *)aRealKey ofType:(NSUInteger)aType withObjCType:(const char*)aObjcType;
-(void)addMethodWithSelector:(SEL)aSelector signature:(NSMethodSignature *)aSignature forKey:(NSString *)aKey ofType:(NSUInteger)aType;
-(void)handleDataForKey:(NSString *)aKey ofType:(NSUInteger)aType forInvocation:(NSInvocation *)anInvocation;

@end
