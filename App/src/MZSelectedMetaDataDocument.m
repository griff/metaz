//
//  MZSelectedMetaDataDocument.m
//  MetaZ
//
//  Created by Brian Olsen on 01/11/12.
//  Copyright 2012 Maven-Group. All rights reserved.
//

#import "MZSelectedMetaDataDocument.h"
#import "MetaZApplication.h"

@implementation MZSelectedTagItem

- (id)value
{
    return [document.data valueForKey:tag.identifier];
}

@end


@implementation MZSelectedMetaDataDocument

- (NSScriptObjectSpecifier *)objectSpecifier;
{
    NSScriptClassDescription *containerClassDesc = (NSScriptClassDescription *)
        [NSScriptClassDescription classDescriptionForClass:[MetaZApplication class]];// 1
    return [[[NSNameSpecifier alloc]
        initWithContainerClassDescription:containerClassDesc
        containerSpecifier:nil key:@"selectedDocuments"
        name:[self displayName]] autorelease];
}

- (NSArray *)tags;
{
    if(!tags)
    {
        NSMutableArray* ret = [NSMutableArray array];
        for(MZTag* tag in [data providedTags])
        {
            [ret addObject:[MZSelectedTagItem itemWithTag:tag document:self]];
        }
        tags = [[NSArray alloc] initWithArray:ret];
    }
    return tags;
}

@end
