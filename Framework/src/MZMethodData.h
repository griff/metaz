//
//  MZMethodData.h
//  MetaZ
//
//  Created by Brian Olsen on 03/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MZMethodData : NSObject {
    SEL selector;
    NSString* key;
    NSUInteger type;
    NSMethodSignature* signature;
}
@property(readonly) SEL selector;
@property(readonly) NSMethodSignature* signature;
@property(readonly) NSUInteger type;
@property(readonly) NSString* key;

+(NSString *)setterForKey:(NSString *)aKey;
+(SEL)setterSelectorForKey:(NSString *)aKey;
+(MZMethodData *)methodSetterForKey:(NSString *)aKey ofType:(NSUInteger)aType withObjCType:(const char*)aObjcType;
+(MZMethodData *)methodSetterForKey:(NSString *)aKey withRealKey:(NSString *)aRealKey ofType:(NSUInteger)aType withObjCType:(const char*)aObjcType;
+(MZMethodData *)methodGetterForKey:(NSString *)aKey ofType:(NSUInteger)aType withObjCType:(const char*)aObjcType;
+(MZMethodData *)methodGetterForKey:(NSString *)aKey withRealKey:(NSString *)aRealKey ofType:(NSUInteger)aType withObjCType:(const char*)aObjcType;
+(MZMethodData *)methodWithSelector:(SEL )aSelector andSignature:(NSMethodSignature *)aSignature forKey:(NSString *)aKey ofType:(NSUInteger)aType;

-(id)initWithSelector:(SEL)aSelector andSignature:(NSMethodSignature *)aSignature forKey:(NSString *)aKey ofType:(NSUInteger)aType;

@end
