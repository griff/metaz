//
//  MZReadOperationsController.m
//  MetaZ
//
//  Created by Brian Olsen on 09/04/10.
//  Copyright 2010 Maven-Group. All rights reserved.
//

#import "MZReadOperationsController.h"
#import "MZTag.h"

@implementation MZReadOperationsController

+ (id)controllerWithProvider:(MZDataProviderPlugin *)provider
                fromFileName:(NSString *)fileName
                    delegate:(id<MZDataReadDelegate>)delegate
                       extra:(NSDictionary *)extra
{
    return [[[[self class] alloc] initWithProvider:provider fromFileName:fileName delegate:delegate extra:extra] autorelease];
}

- (id)initWithProvider:(MZDataProviderPlugin *)theProvider
          fromFileName:(NSString *)theFileName
              delegate:(id<MZDataReadDelegate>)theDelegate
                 extra:(NSDictionary *)extra
{
    self = [super init];
    if(self)
    {
        provider = [theProvider retain];
        fileName = [theFileName retain];
        delegate = [theDelegate retain];
        tagdict = [[NSMutableDictionary alloc] init];
        if(extra)
        {
            for(NSString* key in [extra allKeys])
            {
                MZTag* tag = [MZTag tagForIdentifier:key];
                if(tag)
                {
                    id value = [extra objectForKey:key];
                    value = [tag convertObjectForRetrival:value];
                    [tagdict setObject:[tag convertObjectForStorage:value] forKey:key];
                }
            }
        }
    }
    return self;
}

- (void)dealloc
{
    [provider release];
    [fileName release];
    [delegate release];
    [tagdict release];
    [super dealloc];
}

@synthesize tagdict;

- (void)operationsFinished
{
    MetaLoaded* loaded = nil;
    if(!self.error)
        loaded = [MetaLoaded metaWithOwner:provider filename:fileName dictionary:tagdict];
    [delegate dataProvider:provider
                controller:self
                loadedMeta:loaded
                  fromFile:fileName
                     error:self.error];
}

@end
