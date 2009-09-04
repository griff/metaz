//
//  MetaEdits.m
//  MetaZ
//
//  Created by Brian Olsen on 24/08/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "MetaEdits.h"
#import "MZDataMethod.h"


@implementation MetaEdits

-(id)initWithProvider:(id<MetaData>)aProvider {
    NSArray* keys = [aProvider providedKeys];
    self = [super initWithKeys:keys];
    provider = [aProvider retain];
    tags = [[NSMutableDictionary alloc] init];
    lastCache = [[NSMutableDictionary alloc] init];

    for(NSString *key in keys)
    {
        [provider addObserver: self 
                   forKeyPath: key
                      options: NSKeyValueObservingOptionPrior|NSKeyValueObservingOptionOld
                      context: nil];
        NSString* changedKey = [key stringByAppendingString:@"Changed"];
        [self addMethodGetterForKey:changedKey ofType:2 withObjCType:@encode(BOOL)];
        [self addMethodSetterForKey:key ofType:3 withObjCType:@encode(id)];
        [self addMethodSetterForKey:changedKey ofType:4 withObjCType:@encode(BOOL)];
    }

    return self;
}

- (void)dealloc {
    NSArray* keys = [provider providedKeys];
    for(NSString *key in keys)
        [provider removeObserver:self forKeyPath: key];
    [provider release];
    [lastCache release];
    [super dealloc];
}

-(NSArray *)providedKeys {
    return [provider providedKeys];
}

-(BOOL)changed {
    return [tags count] > 0;
}

-(id)getterValueForKey:(NSString *)aKey {
    id ret = [tags objectForKey:aKey];
    if(ret != nil) // Not Changed
    {
        if(ret == [NSNull null])
            return nil;
        return ret;
    }
    return [provider performSelector:NSSelectorFromString(aKey)];
}

-(BOOL)getterChangedForKey:(NSString *)aKey {
    return [tags objectForKey:aKey] != nil;
}

-(void)setterChanged:(BOOL)aValue forKey:(NSString *)aKey {
    id oldValue = [tags objectForKey:aKey];
    if(!aValue && oldValue!=nil)
    {
        if([tags count] == 1)
            [self willChangeValueForKey:@"changed"];
        [lastCache setObject:oldValue forKey:aKey];
        [tags removeObjectForKey:aKey];
        if([tags count] == 0)
            [self didChangeValueForKey:@"changed"];
    }
    else if(aValue && oldValue==nil)
    {
        if([tags count] == 0)
            [self willChangeValueForKey:@"changed"];
        [self willChangeValueForKey:aKey];
        oldValue = [lastCache objectForKey:aKey];
        if(oldValue==nil)
            oldValue = [self performSelector:NSSelectorFromString(aKey)];

        if(oldValue == nil)
            oldValue = [NSNull null];

        [tags setObject:oldValue forKey:aKey];
        [self didChangeValueForKey:aKey];
        if([tags count] == 1)
            [self didChangeValueForKey:@"changed"];
    }
}

-(void)setterValue:(id)aValue forKey:(NSString *)aKey {
    BOOL changedUpdated = [tags objectForKey:aKey] == nil;
    NSString* changedKey = [aKey stringByAppendingString:@"Changed"];
    if(aValue == nil)
        aValue = [NSNull null];
    if(changedUpdated) {
        [self willChangeValueForKey:changedKey];
        if([tags count] == 0)
            [self willChangeValueForKey:@"changed"];
    }
    [lastCache removeObjectForKey:aKey];
    [tags setObject:aValue forKey:aKey];
    if(changedUpdated) {
        [self didChangeValueForKey:changedKey];
        if([tags count] == 1)
            [self didChangeValueForKey:@"changed"];
    }
}


-(void)handleDataForKey:(NSString *)aKey ofType:(NSUInteger)aType forInvocation:(NSInvocation *)anInvocation {
    if(aType == 1) // Get value
    {
        id ret = [self getterValueForKey:aKey];
        [anInvocation setReturnValue: &ret];
        return;
    }
    if( aType == 2) // Get Changed Value
    {
        BOOL ret = [self getterChangedForKey:aKey];
        [anInvocation setReturnValue: &ret];
        return;
    }
    if(aType == 3) // Set Value
    {
        id value;
        [anInvocation getArgument:&value atIndex:2];
        [self setterValue:value forKey:aKey];
        return;
    }
    if(aType == 4) // Set Changed value
    {
        BOOL newChanged;
        [anInvocation getArgument:&newChanged atIndex:2];
        [self setterChanged:newChanged forKey:aKey];
        return;
    }
}

- (id)valueForUndefinedKey:(NSString *)key {
    if([self respondsToSelector:NSSelectorFromString(key)])
    {
        if([key hasSuffix:@"Changed"])
        {
            NSString* valueKey = [key substringToIndex:[key length]-7];
            BOOL ret = [self getterChangedForKey:valueKey];
            return [NSNumber numberWithBool:ret];
        }
        return [self getterValueForKey:key];
    }
    return [super valueForUndefinedKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if([self respondsToSelector:NSSelectorFromString(key)])
    {
        if([key hasSuffix:@"Changed"])
        {
            NSString* valueKey = [key substringToIndex:[key length]-7];
            BOOL newChanged = [value boolValue];
            [self setterChanged:newChanged forKey:valueKey];
            return;
        }
        [self setterValue:value forKey:key];
        return;
    }
    [super setValue:value forUndefinedKey:key];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    id value = [tags objectForKey:keyPath];
    if(value == nil)
    {
        NSNumber * prior = [change objectForKey:NSKeyValueChangeNotificationIsPriorKey];
        if([prior boolValue])
            [self willChangeValueForKey:keyPath];
        else
            [self didChangeValueForKey:keyPath];
    }
}

/*
- (id)valueForUndefinedKey:(NSString *)key {
    if([key hasSuffix:@"Changed"])
    {
        NSString* valueKey = [key substringToIndex:[key length]-7];
        [provider valueForKey:valueKey]; // Fails when key not supported
        id value = [tags objectForKey:valueKey];
        return [NSNumber numberWithBool:(value!=nil)];
    }
    BOOL changed = [[self valueForKey:[key stringByAppendingString:@"Changed"]] boolValue];
    if(changed)
        return [tags objectForKey:key];
    if(provider)
        return [provider valueForKey:key];
    return [super valueForUndefinedKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if([key hasSuffix:@"Changed"])
    {
        BOOL newChanged = [value boolValue];
        NSString* valueKey = [key substringToIndex:[key length]-7];
        id oldValue = [tags objectForKey:valueKey];
        if(!newChanged && oldValue!=nil)
            [tags removeObjectForKey:valueKey];
        else if(newChanged && oldValue==nil)
        {
            oldValue = [self valueForKey:valueKey];
            [tags setObject:oldValue forKey:valueKey];
        }
        return;
    }

    BOOL changedUpdated = [tags objectForKey:key] == nil;
    NSString* changedKey = [key stringByAppendingString:@"Changed"];
    if(value == nil)
        value = [NSNull null];
    if(changedUpdated) [self willChangeValueForKey:changedKey];
    [tags setObject:value forKey:key];
    if(changedUpdated) [self didChangeValueForKey:changedKey];
}
*/

@end
