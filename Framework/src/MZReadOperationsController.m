//
//  MZReadOperationsController.m
//  MetaZ
//
//  Created by Brian Olsen on 09/04/10.
//  Copyright 2010 Maven-Group. All rights reserved.
//

#import "MZReadOperationsController.h"


@implementation MZReadOperationsController

+ (id)controllerWithProvider:(id<MZDataProvider>)provider
                fromFileName:(NSString *)fileName
                    delegate:(id<MZDataReadDelegate>)delegate
{
    return [[[[self class] alloc] initWithProvider:provider fromFileName:fileName delegate:delegate] autorelease];
}

- (id)initWithProvider:(id<MZDataProvider>)theProvider
          fromFileName:(NSString *)theFileName
              delegate:(id<MZDataReadDelegate>)theDelegate
{
    self = [super init];
    if(self)
    {
        provider = [theProvider retain];
        fileName = [theFileName retain];
        delegate = [theDelegate retain];
        tagdict = [[NSMutableDictionary alloc] init];
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
