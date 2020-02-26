//
//  PicturesArrayController.m
//  MetaZ
//
//  Created by Brian Olsen on 14/11/12.
//  Copyright 2012 Maven-Group. All rights reserved.
//

#import "PicturesArrayController.h"

@implementation PicturesArrayController

- (BOOL)canApply:(id)data;
{
    if([[data objectForKey:MZPictureTagIdent] isKindOfClass:[NSArray class]])
    {
        id picture = [self valueForKeyPath:@"selection.self"];
        if([picture isKindOfClass:[RemoteData class]])
        {
            if(![picture isLoaded])
                return NO;
        }
    }
    return YES;
}

- (void)applyData:(id)data toEdit:(MetaEdits *)edit;
{
    if([[data objectForKey:MZPictureTagIdent] isKindOfClass:[NSArray class]])
    {
        id picture = [self valueForKeyPath:@"selection.self"];
        if([picture isKindOfClass:[RemoteData class]])
            picture = [picture data];
        if(picture)
            [edit setterValue:picture forKey:MZPictureTagIdent];
    }
}

- (void) bind:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath options:(NSDictionary *)options
{
    [super bind:binding toObject:observable withKeyPath:keyPath options:options];
    if([observable conformsToProtocol:@protocol(MZApplyController)])
        [observable registerEditor:self];
}

- (void)unbind:(NSString *)binding
{
    NSDictionary* dict = [self infoForBinding:binding];
    id observable = [dict objectForKey:NSObservedObjectKey];
    if([observable conformsToProtocol:@protocol(MZApplyController)])
        [observable unregisterEditor:self];
    
    [super unbind:binding];
}

@end
