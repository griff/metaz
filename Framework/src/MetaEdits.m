//
//  MetaEdits.m
//  MetaZ
//
//  Created by Brian Olsen on 24/08/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <MetaZKit/MetaEdits.h>
#import <MetaZKit/MZMethodData.h>
#import <MetaZKit/MZConstants.h>
#import <MetaZKit/MZTag.h>
#import "PureMetaEdits.h"
//#import <MetaZKit/MetaChangeNotification.h>


@implementation MetaEdits
@synthesize undoManager;
@synthesize changes;
@synthesize provider;
@synthesize pure;

#pragma mark - initialization

- (id)initWithProvider:(id<MetaData>)aProvider {
    self = [super init];
    if(self)
    {
        undoManager = [[MetaEditsUndoManager alloc] init];
        provider = [aProvider retain];
        changes = [[NSMutableDictionary alloc] init];
        pure = [[PureMetaEdits alloc] initWithEdits:self];

        NSArray* tags = [aProvider providedTags];
        for(MZTag* tag in tags)
        {
            NSString* key = [tag identifier];
            [provider addObserver: self 
                       forKeyPath: key
                          options: NSKeyValueObservingOptionPrior|NSKeyValueObservingOptionOld
                          context: nil];
            NSString* changedKey = [key stringByAppendingString:@"Changed"];
            [self addMethodGetterForKey:key ofType:1 withObjCType:[tag encoding]];
            [self addMethodGetterForKey:changedKey withRealKey:key ofType:2 withObjCType:@encode(BOOL)];
            [self addMethodSetterForKey:key ofType:3 withObjCType:[tag encoding]];
            [self addMethodSetterForKey:changedKey withRealKey:key ofType:4 withObjCType:@encode(BOOL)];
        }
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]
        postNotificationName:MZMetaEditsDeallocating
                      object:self];
    
    NSArray* tags = [provider providedTags];
    for(MZTag *tag in tags)
        [provider removeObserver:self forKeyPath: [tag identifier]];
    [pure dealloc];
    [changes release];
    [provider release];
    [undoManager release];
    [super dealloc];
}

- (id)owner
{
    return [provider owner];
}

- (NSArray *)providedTags
{
    return [provider providedTags];
}

- (NSString *)loadedFileName
{
    return [provider loadedFileName];
}

- (NSString *)savedFileName
{
    return [[[self loadedFileName] stringByDeletingLastPathComponent]
        stringByAppendingPathComponent:[self fileName]];
}

- (NSString *)savedTempFileName
{
    NSString* tempFile = [self savedFileName];
    NSString* ext = [tempFile pathExtension];
    tempFile = [[tempFile stringByDeletingPathExtension] stringByAppendingString:@" MetaZ"];
    if(ext && [ext length] > 0)
        return [tempFile stringByAppendingFormat:@".%@", ext];
    return tempFile;
}

- (void)prepareForQueue
{
    [provider prepareForQueue];
}

- (void)prepareFromQueue
{
    [provider prepareFromQueue];
}

-(BOOL)changed
{
    /*
    int count = [changes objectForKey:MZFileNameTag] != nil ? 1 : 0;
    return [changes count] > count;
    */
    return [changes count] > 0;
}

-(id)getterValueForKey:(NSString *)aKey
{
    id ret = [changes objectForKey:aKey];
    if(ret != nil) // Changed
    {
        MZTag* tag = [MZTag tagForIdentifier:aKey];
        return [tag convertObjectForRetrival:ret];
    }
    
    return [provider valueForKey:aKey]; //[provider performSelector:NSSelectorFromString(aKey)];
}

-(BOOL)getterChangedForKey:(NSString *)aKey
{
    return [changes objectForKey:aKey] != nil;
}

-(void)setterChanged:(BOOL)aValue forKey:(NSString *)aKey
{
    id oldValue = [changes objectForKey:aKey];
    if(!aValue && oldValue!=nil)
    {
        [[[self undoManager] prepareWithInvocationTarget:self] setterValue:oldValue forKey:aKey];
        MZTag* tag = [MZTag tagForIdentifier:aKey];
        NSString* actionKey = [tag localizedName];
        if(!actionKey)
            actionKey = aKey;
        if([[self undoManager] isUndoing])
        {
            [[self undoManager] setActionName:
                [NSString stringWithFormat:
                    NSLocalizedString(@"Set %@", @"Undo set action"),
                    actionKey]];
        }
        else
        {
            [[self undoManager] setActionName:
                [NSString stringWithFormat:
                    NSLocalizedString(@"Reverted %@", @"Undo reverted action"),
                    actionKey]];
        }
        
        if([changes count] == 1)
            [self willChangeValueForKey:@"changed"];
        NSString* changedKey = [aKey stringByAppendingString:@"Changed"];
        [self willChangeValueForKey:changedKey];
        [self willChangeValueForKey:aKey];
        [pure willChangeValueForKey:aKey];
        [changes removeObjectForKey:aKey];
        [self didChangeValueForKey:aKey];
        [pure didChangeValueForKey:aKey];
        [self didChangeValueForKey:changedKey];
        if([changes count] == 0)
            [self didChangeValueForKey:@"changed"];
    }
    else if(aValue && oldValue==nil)
    {
        [[[self undoManager] prepareWithInvocationTarget:self] setterChanged:NO forKey:aKey];
        MZTag* tag = [MZTag tagForIdentifier:aKey];
        NSString* actionKey = [tag localizedName];
        if(!actionKey)
            actionKey = aKey;
            
        [[self undoManager] setActionName:
            [NSString stringWithFormat:
                NSLocalizedString(@"Set %@", @"Undo set action"),
                actionKey]];
        
        if([changes count] == 0)
            [self willChangeValueForKey:@"changed"];
        NSString* changedKey = [aKey stringByAppendingString:@"Changed"];
        [self willChangeValueForKey:changedKey];
        [self willChangeValueForKey:aKey];
        [pure willChangeValueForKey:aKey];
        [self willStoreValueForKey:aKey];
        oldValue = [self valueForKey:aKey]; //[self performSelector:NSSelectorFromString(aKey)];
        oldValue = [tag convertObjectForStorage:oldValue];

        [changes setObject:oldValue forKey:aKey];
        [self didStoreValueForKey:aKey];
        [self didChangeValueForKey:aKey];
        [pure didChangeValueForKey:aKey];
        [self didChangeValueForKey:changedKey];
        if([changes count] == 1)
            [self didChangeValueForKey:@"changed"];
    }
}

-(void)setterValue:(id)aValue forKey:(NSString *)aKey
{
    MZTag* tag = [MZTag tagForIdentifier:aKey];
    id oldValue = [changes objectForKey:aKey];
    aValue = [tag convertObjectForStorage:aValue];

    id pureValue = [pure valueForKey:aKey];
    pureValue = [tag convertObjectForStorage:pureValue];
    BOOL pureModified = (pureValue != aValue) &&
        !(pureValue && aValue && [pureValue isEqual:aValue]);

    /*
    id currentValue = [provider valueForKey:aKey];
    currentValue = [tag convertObjectForStorage:currentValue];
    
    // If reverted to old value 
    if([aValue isEqual:currentValue])
    {
        if(oldValue == nil)
            return;
        [self setterChanged:NO forKey:aKey];
        return;
    }
    */
    
    if(oldValue==nil)
    {
        [[[self undoManager] prepareWithInvocationTarget:self] setterChanged:NO forKey:aKey];
        NSString* actionKey = [tag localizedName];
        if(!actionKey)
            actionKey = aKey;
        [[self undoManager] setActionName:
            [NSString stringWithFormat:
                NSLocalizedString(@"Set %@", @"Undo set action"),
                actionKey]];
    } else
    {
        [[[self undoManager] prepareWithInvocationTarget:self] setterValue:oldValue forKey:aKey];
        NSString* actionKey = [tag localizedName];
        if(!actionKey)
            actionKey = aKey;
        [[self undoManager] setActionName:
            [NSString stringWithFormat:
                NSLocalizedString(@"Changed %@", @"Undo changed action"),
                actionKey]];
    }
    
    NSString* changedKey = [aKey stringByAppendingString:@"Changed"];
    if(oldValue == nil)
    {
        [self willChangeValueForKey:changedKey];
        if([changes count] == 0)
            [self willChangeValueForKey:@"changed"];
    }
    [self willChangeValueForKey:aKey];
    if(pureModified)
        [pure willChangeValueForKey:aKey];
    [changes setObject:aValue forKey:aKey];
    [self didChangeValueForKey:aKey];
    if(pureModified)
        [pure didChangeValueForKey:aKey];
    if(oldValue == nil)
    {
        [self didChangeValueForKey:changedKey];
        if([changes count] == 1)
            [self didChangeValueForKey:@"changed"];
    }
}

#pragma mark - MZDynamicObject handling

-(void)handleDataForKey:(NSString *)aKey ofType:(NSUInteger)aType forInvocation:(NSInvocation *)anInvocation
{
    if(aType == 1) // Get value
    {
        id ret = [self getterValueForKey:aKey];
        [anInvocation setReturnObject:ret];
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
        id value = [anInvocation argumentObjectAtIndex:2];
        //[anInvocation getArgument:&value atIndex:2];
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

-(id)handleDataForMethod:(NSString *)aMethod withKey:(NSString *)aKey ofType:(NSUInteger)aType
{
    if(aType == 1) // Get value
        return [self getterValueForKey:aKey];
    if( aType == 2) // Get Changed Value
    {
        BOOL ret = [self getterChangedForKey:aKey];
        return [NSNumber numberWithBool:ret];
    }
}

-(void)handleSetData:(id)value forMethod:(NSString *)aMethod withKey:(NSString *)aKey ofType:(NSUInteger)aType
{
    if(aType == 3) // Set Value
    {
        [self setterValue:value forKey:aKey];
        return;
    }
    if(aType == 4) // Set Changed value
    {
        BOOL newChanged = [value boolValue];
        [self setterChanged:newChanged forKey:aKey];
        return;
    }
}

#pragma mark - observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(object == provider)
    {
        id value = [changes objectForKey:keyPath];
        if(value == nil)
        {
            NSNumber * prior = [change objectForKey:NSKeyValueChangeNotificationIsPriorKey];
            if([prior boolValue])
                [self willChangeValueForKey:keyPath];
            else
                [self didChangeValueForKey:keyPath];
        }
    }
}

- (BOOL)isEqual:(id)other
{
    return [super isEqual:other];
}

#pragma mark - NSCoding implementation

- (id)initWithCoder:(NSCoder *)decoder
{
    id aProvider;
    if([decoder allowsKeyedCoding])
        aProvider = [decoder decodeObjectForKey:@"provider"];
    else
        aProvider = [decoder decodeObject];
        
    self = [self initWithProvider:aProvider];
    
    if([decoder allowsKeyedCoding])
        [changes addEntriesFromDictionary:[decoder decodeObjectForKey:@"changes"]];
    else
        [changes addEntriesFromDictionary:[decoder decodeObject]];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    if([encoder allowsKeyedCoding])
    {
        [encoder encodeObject:provider forKey:@"provider"];
        [encoder encodeObject:changes forKey:@"changes"];
    }
    else
    {
        [encoder encodeObject:provider];
        [encoder encodeObject:changes];
    }
}

#pragma mark - NSCopying implementation

- (id)copyWithZone:(NSZone *)zone
{
    id ret = [[provider copyWithZone:zone] autorelease];
    MetaEdits* copy = [[MetaEdits allocWithZone:zone] initWithProvider:ret];
    [copy->changes addEntriesFromDictionary:changes];
    return copy;
}

@end
