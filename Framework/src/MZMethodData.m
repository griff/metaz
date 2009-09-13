//
//  MZMethodData.m
//  MetaZ
//
//  Created by Brian Olsen on 03/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "MZMethodData.h"


@implementation MZMethodData
@synthesize selector;
@synthesize signature;
@synthesize key;
@synthesize type;

+(NSString *)setterForKey:(NSString *)aKey {
    NSString* pre = [aKey substringToIndex:1];
    pre = [pre uppercaseString];
    return [NSString stringWithFormat:@"set%@%@:", pre, [aKey substringFromIndex:1]];
}

+(SEL)setterSelectorForKey:(NSString *)aKey {
    return NSSelectorFromString([MZMethodData setterForKey:aKey]);
}

+(MZMethodData *)methodSetterForKey:(NSString *)aKey ofType:(NSUInteger)aType withObjCType:(const char*)aObjcType {
    return [MZMethodData methodSetterForKey:aKey withRealKey:aKey ofType:aType withObjCType:aObjcType];
}

+(MZMethodData *)methodSetterForKey:(NSString *)aKey withRealKey:(NSString *)aRealKey ofType:(NSUInteger)aType withObjCType:(const char*)aObjcType {
    char sigc[sizeof(aObjcType)+3] = "v@:";
    if(strlcat(sigc, aObjcType, sizeof(sigc)) >= sizeof(sigc))
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Bad type" userInfo:nil];
    NSMethodSignature* sig = [NSMethodSignature signatureWithObjCTypes:sigc];
    SEL sel = NSSelectorFromString([MZMethodData setterForKey:aKey]);
    return [MZMethodData methodWithSelector:sel signature:sig forKey:aRealKey ofType:aType];
}

+(MZMethodData *)methodGetterForKey:(NSString *)aKey ofType:(NSUInteger)aType withObjCType:(const char*)aObjcType {
    return [MZMethodData methodGetterForKey:aKey withRealKey:aKey ofType:aType withObjCType:aObjcType];
}

+(MZMethodData *)methodGetterForKey:(NSString *)aKey withRealKey:(NSString *)aRealKey ofType:(NSUInteger)aType withObjCType:(const char*)aObjcType {
    char sigc[sizeof(aObjcType)+2];
    if(strlcpy(sigc, aObjcType, sizeof(sigc)) >= sizeof(sigc))
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Bad type" userInfo:nil];
    if(strlcat(sigc, "@:", sizeof(sigc)) >= sizeof(sigc))
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Bad type" userInfo:nil];
    
    NSMethodSignature* sig = [NSMethodSignature signatureWithObjCTypes:sigc];
    SEL sel = NSSelectorFromString(aKey);
    return [MZMethodData methodWithSelector:sel signature:sig forKey:aRealKey ofType:aType];
}

+(MZMethodData *)methodWithSelector:(SEL )aSelector signature:(NSMethodSignature *)aSignature forKey:(NSString *)aKey ofType:(NSUInteger)aType {
  MZMethodData * ret = [[MZMethodData alloc] initWithSelector:aSelector signature:aSignature forKey:aKey ofType:aType];
  return [ret autorelease];
}

-(id)initWithSelector:(SEL)aSelector signature:(NSMethodSignature*)aSignature forKey:(NSString *)aKey ofType:(NSUInteger)aType {
    self = [super init];
    selector = aSelector;
    signature = [aSignature retain];
    key = [aKey retain];
    type = aType;
    return self;
}

-(void)dealloc {
    [signature release];
    [key release];
    [super dealloc];
}

@end
