//
//  SearchMeta.m
//  MetaZ
//
//  Created by Brian Olsen on 04/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <MetaZKit/SearchMeta.h>

@implementation SearchMeta

-(id)initWithProvider:(id<MetaData>)aProvider controller:(NSArrayController *)aController {
    self = [super init];
    searchController = [aController retain];
    provider = [aProvider retain];
    NSArray* keys = [aProvider providedKeys];
    for(NSString *key in keys)
    {
        [searchController addObserver:self 
                           forKeyPath:[@"selection." stringByAppendingString:key]
                              options:NSKeyValueObservingOptionPrior|NSKeyValueObservingOptionOld
                              context:nil];
        [provider addObserver:self 
                   forKeyPath:key
                      options:NSKeyValueObservingOptionPrior|NSKeyValueObservingOptionOld
                      context:nil];
        [self addMethodGetterForKey:key ofType:1 withObjCType:@encode(id)];
    }
    return self;
}

- (void)dealloc {
    NSArray* keys = [provider providedKeys];
    for(NSString *key in keys)
    {
        [searchController removeObserver:self forKeyPath: [@"selection." stringByAppendingString:key]];
        [provider removeObserver:self forKeyPath:key];
    }
    [provider release];
    [searchController release];
    [super dealloc];
}

- (id)owner
{
    return [provider owner];
}

-(NSArray *)providedKeys {
    return [provider providedKeys];
}

-(NSString *)loadedFileName {
    return [provider loadedFileName];
}

-(NSString *)fileName {
    return [provider fileName];
}


-(id)getterValueForKey:(NSString *)aKey {
    id ret = nil;
    @try {
        ret = [searchController valueForKeyPath:[@"selection." stringByAppendingString:aKey]];
    }
    @catch (NSException * e) {
        NSLog(@"Auch %@", e);
    }
    if(ret == nil)
        return [provider performSelector:NSSelectorFromString(aKey)];
    return ret;
}

-(void)willStoreValueForKey:(NSString *)key
{
    [provider willStoreValueForKey:key];
}

-(void)didStoreValueForKey:(NSString *)key
{
    [provider didStoreValueForKey:key];
}


-(void)handleDataForKey:(NSString *)aKey ofType:(NSUInteger)aType forInvocation:(NSInvocation *)anInvocation {
    id ret = [self getterValueForKey:aKey];
    [anInvocation setReturnValue:&ret];
}

- (id)valueForUndefinedKey:(NSString *)key {
    if([self respondsToSelector:NSSelectorFromString(key)])
        return [self getterValueForKey:key];
    return [super valueForUndefinedKey:key];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if(object == provider)
    {
        NSNumber * prior = [change objectForKey:NSKeyValueChangeNotificationIsPriorKey];
        if([prior boolValue])
            [self willChangeValueForKey:keyPath];
        else
            [self didChangeValueForKey:keyPath];
    } else if(object == searchController)
    {
        NSString* key = [keyPath substringFromIndex:10];
        NSNumber * prior = [change objectForKey:NSKeyValueChangeNotificationIsPriorKey];
        if([prior boolValue])
            [self willChangeValueForKey:key];
        else
            [self didChangeValueForKey:key];
    }
}

#pragma mark - NSCoding implementation

- (Class)classForCoder {
    return [provider classForCoder];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    // Not possible
    NSException* myException = [NSException
        exceptionWithName:@"NotImplementedException"
                   reason:@"Method is not implemented in class"
                 userInfo:nil];
    @throw myException;
/*
    NSDictionary* dict;
    NSString* loadedFile;
    if([decoder allowsKeyedCoding])
    {
        loadedFile = [decoder decodeObjectForKey:@"loadedFileName"];
        dict = [decoder decodeObjectForKey:@"tags"];
    }
    else
    {
        loadedFile = [decoder decodeObject];
        dict = [decoder decodeObject];
    }
    return [self initWithFilename:loadedFile dictionary:dict];
*/
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [provider encodeWithCoder:encoder];
}

#pragma mark - NSCopying implementation

- (id)copyWithZone:(NSZone *)zone
{
    // For now simple remove SearchMeta from the chain
    return [provider copyWithZone:zone];
}

- (id<MetaData>)queueCopy
{
    return [provider copy];
}

@end
