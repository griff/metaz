//
//  SearchMeta.m
//  MetaZ
//
//  Created by Brian Olsen on 04/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "SearchMeta.h"

@implementation SearchMeta

-(id)initWithProvider:(id<MetaData>)aProvider controller:(NSArrayController *)aController
{
    self = [super init];
    if(self)
    {
        searchController = [aController retain];
        provider = [aProvider retain];
        observeFix = [[MZPriorObserverFix alloc] initWithOther:searchController];
        NSMutableArray* tags = [NSMutableArray arrayWithArray:[aProvider providedTags]];
        [tags removeObject:[MZTag tagForIdentifier:MZFileNameTagIdent]];
        for(MZTag* tag in tags)
        {
            NSString* key = [tag identifier];
            [observeFix addObserver:self 
                         forKeyPath:[@"selection." stringByAppendingString:key]
                            options:NSKeyValueObservingOptionPrior
                            context:NULL];
            [provider addObserver:self 
                       forKeyPath:key
                          options:NSKeyValueObservingOptionPrior
                          context:NULL];
            [self addMethodGetterForKey:key ofType:1 withObjCType:[tag encoding]];
        }
        [provider addObserver:self 
                   forKeyPath:MZFileNameTagIdent
                      options:NSKeyValueObservingOptionPrior
                      context:NULL];
    }
    return self;
}

- (void)dealloc
{
    NSMutableArray* tags = [NSMutableArray arrayWithArray:[provider providedTags]];
    [tags removeObject:[MZTag tagForIdentifier:MZFileNameTagIdent]];
    for(MZTag* tag in tags)
    {
        NSString* key = [tag identifier];
        [observeFix removeObserver:self forKeyPath: [@"selection." stringByAppendingString:key]];
        [provider removeObserver:self forKeyPath:key];
    }
    [provider removeObserver:self forKeyPath:MZFileNameTagIdent];
    [provider release];
    [observeFix release];
    [searchController release];
    [super dealloc];
}

- (id)owner
{
    return [provider owner];
}

-(NSArray *)providedTags
{
    return [provider providedTags];
}

-(NSString *)loadedFileName
{
    return [provider loadedFileName];
}

-(NSString *)fileName
{
    return [provider fileName];
}

- (id<TagData>)pure
{
    return [provider pure];
}

- (void)prepareForQueue
{
    ignoreController = YES;
    NSMutableArray* tags = [NSMutableArray arrayWithArray:[provider providedTags]];
    [tags removeObject:[MZTag tagForIdentifier:MZFileNameTagIdent]];
    for(MZTag* tag in tags)
    {
        NSString* key = [tag identifier];
        [observeFix removeObserver:self forKeyPath: [@"selection." stringByAppendingString:key]];
    }
    [provider prepareForQueue];
}

- (void)prepareFromQueue
{
    ignoreController = NO;
    NSMutableArray* tags = [NSMutableArray arrayWithArray:[provider providedTags]];
    [tags removeObject:[MZTag tagForIdentifier:MZFileNameTagIdent]];
    for(MZTag* tag in tags)
    {
        NSString* key = [tag identifier];
        [observeFix addObserver:self 
                     forKeyPath:[@"selection." stringByAppendingString:key]
                        options:NSKeyValueObservingOptionPrior
                        context:NULL];
    }
    [provider prepareFromQueue];
}


-(id)getterValueForKey:(NSString *)aKey
{
    id ret = nil;
    if(!ignoreController)
        ret = [searchController protectedValueForKeyPath:[@"selection." stringByAppendingString:aKey]];
    if(ret == nil || ret == NSNotApplicableMarker || ret == NSNoSelectionMarker)
        return [provider valueForKey:aKey];
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


-(void)handleDataForKey:(NSString *)aKey ofType:(NSUInteger)aType forInvocation:(NSInvocation *)anInvocation
{
    id ret = [self getterValueForKey:aKey];
    [anInvocation setReturnObject:ret];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(object == provider)
    {
        NSNumber * prior = [change objectForKey:NSKeyValueChangeNotificationIsPriorKey];
        if([prior boolValue])
            [self willChangeValueForKey:keyPath];
        else
            [self didChangeValueForKey:keyPath];
    } else if(!ignoreController && (object == searchController || object == observeFix))
    {
        NSString* key = [keyPath substringFromIndex:10];
        NSNumber * prior = [change objectForKey:NSKeyValueChangeNotificationIsPriorKey];
        if([prior boolValue])
        {
            //if([key isEqual:MZRatingTagIdent])
            //MZLoggerDebug(@"Changing %@ old: '%@'", key, [object protectedValueForKeyPath:keyPath]);
            [self willChangeValueForKey:key];
        }
        else
        {
            [self didChangeValueForKey:key];
            //if([key isEqual:MZRatingTagIdent])
            //MZLoggerDebug(@"Changing %@ new: '%@'", key, [object protectedValueForKeyPath:keyPath]);
        }
    }
}

#pragma mark - NSCoding implementation

/*
- (Class)classForCoder
{
    return [provider classForCoder];
}
*/

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    [self release];
    
    MetaLoaded* theProvider;
    if([decoder allowsKeyedCoding])
        theProvider = [decoder decodeObjectForKey:@"provider"];
    else {
        theProvider = [decoder decodeObject];
    }
    
    id<MZPluginControllerDelegate> delegate = [[MZPluginController sharedInstance] delegate];
    if([delegate respondsToSelector:@selector(pluginController:extraMetaDataForProvider:loaded:)])
    {
        SearchMeta* newMeta = [delegate pluginController:[MZPluginController sharedInstance]
                extraMetaDataForProvider:[theProvider owner] loaded:theProvider];
        if(newMeta)
        {
            newMeta->ignoreController = ignoreController;
            return [newMeta retain];
        }
    }
    
    // No delegate so delete myself.
    [self release];
    return [theProvider retain];
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    if([encoder allowsKeyedCoding])
        [encoder encodeObject:provider forKey:@"provider"];
    else
        [encoder encodeObject:provider];
}

#pragma mark - NSCopying implementation

- (id)copyWithZone:(NSZone *)zone
{
    id theProvider = [[provider copyWithZone:zone] autorelease];
    SearchMeta* ret = [[[self class] alloc] initWithProvider:theProvider controller:searchController];
    ret->ignoreController = ignoreController;
    return ret;
}

@end
