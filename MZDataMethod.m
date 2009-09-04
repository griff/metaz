//
//  MZDataMethod.m
//  MetaZ
//
//  Created by Brian Olsen on 03/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "MZDataMethod.h"


@implementation MZDataMethod
@synthesize selector;
@synthesize signature;
@synthesize key;
@synthesize type;

+(NSString *)setterForKey:(NSString *)aKey {
    NSString* pre = [aKey substringToIndex:1];
    pre = [pre uppercaseString];
    return [NSString stringWithFormat:@"set%@%@:", pre, [aKey substringFromIndex:1]];
}

+(MZDataMethod *)methodSetterForKey:(NSString *)aKey ofType:(NSUInteger)aType withObjCType:(const char*)aObjcType {
    char sigc[sizeof(aObjcType)+3] = "v@:";
    if(strlcat(sigc, aObjcType, sizeof(sigc)) >= sizeof(sigc))
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Bad type" userInfo:nil];
    NSMethodSignature* sig = [NSMethodSignature signatureWithObjCTypes:sigc];
    SEL sel = NSSelectorFromString([MZDataMethod setterForKey:aKey]);
    return [MZDataMethod methodWithSelector:sel andSignature:sig forKey:aKey ofType:aType];
}

+(MZDataMethod *)methodGetterForKey:(NSString *)aKey ofType:(NSUInteger)aType withObjCType:(const char*)aObjcType {
    char sigc[sizeof(aObjcType)+2];
    if(strlcpy(sigc, aObjcType, sizeof(sigc)) >= sizeof(sigc))
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Bad type" userInfo:nil];
    if(strlcat(sigc, "@:", sizeof(sigc)) >= sizeof(sigc))
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Bad type" userInfo:nil];
    
    NSMethodSignature* sig = [NSMethodSignature signatureWithObjCTypes:sigc];
    SEL sel = NSSelectorFromString(aKey);
    return [MZDataMethod methodWithSelector:sel andSignature:sig forKey:aKey ofType:aType];
}


+(MZDataMethod *)methodWithSelector:(SEL )aSelector andSignature:(NSMethodSignature *)aSignature forKey:(NSString *)aKey ofType:(NSUInteger)aType {
  MZDataMethod * ret = [[MZDataMethod alloc] initWithSelector:aSelector andSignature:aSignature forKey:aKey ofType:aType];
  return [ret autorelease];
}

-(id)initWithSelector:(SEL)aSelector andSignature:(NSMethodSignature*)aSignature forKey:(NSString *)aKey ofType:(NSUInteger)aType {
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
