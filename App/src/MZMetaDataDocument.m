//
//  MZMetaDataDocument.m
//  MetaZ
//
//  Created by Brian Olsen on 15/07/12.
//  Copyright 2012 Maven-Group. All rights reserved.
//

#import "MZMetaDataDocument.h"
#import "MetaZApplication.h"

@implementation MZTagItem

+ (id)itemWithTag:(MZTag*)theTag document:(MZMetaDataDocument *)theDocument;
{
    return [[[self alloc] initWithTag:theTag document:theDocument] autorelease];
}

- (id)initWithTag:(MZTag*)theTag document:(MZMetaDataDocument *)theDocument;
{
    self = [super init];
    if(self) {
        tag = [theTag retain];
        document = theDocument;
    }
    return self;
}

- (void)dealloc
{
    [tag release];
    //[document release];
    [super dealloc];
}


- (NSString *)name
{
    return tag.scriptName;
}

- (id)value
{
    return [document.data valueForKey:tag.identifier];
}

- (void)setValue:(id)val
{
    [document.data setValue:val forKey:tag.identifier];
}

- (id)coerceValue:(id)value forKey:(NSString *)key
{
    if ([value isKindOfClass:[NSAppleEventDescriptor class]]) {
        DescType descType = [value descriptorType];

        switch(descType) {
            case typeUnicodeText:
                value = [value stringValue];
                break;
            case typeSInt32:
                value = [NSNumber numberWithInt:[value int32Value]];
                break;
/*            case typeObjectSpecifier:
                
                break; */
            default:
                value = nil;
                break;
        }
    }
    return value;
}

- (NSScriptObjectSpecifier *)objectSpecifier;
{
    NSScriptObjectSpecifier* objectSpecifier = [document objectSpecifier];
    return [[[NSNameSpecifier alloc] 
        initWithContainerClassDescription:[objectSpecifier keyClassDescription]
                       containerSpecifier:objectSpecifier
                                      key:@"tags"
                                    name:self.name] autorelease];
}

@end


@implementation MZMetaDataDocument

+ (id)documentWithEdit:(MetaEdits *)edit;
{
    return [[[self alloc] initWithEdit:edit] autorelease];
}

- (id)initWithEdit:(MetaEdits *)edit;
{
    self = [super init];
    if(self)
    {
        data = [edit retain];
    }
    return self;
}

- (void)dealloc
{
    [data release];
    [tags release];
    [super dealloc];
}

@synthesize data;

- (NSString *)lastComponentOfFileName;
{
    return [[data loadedFileName] lastPathComponent];
}

- (NSString *)displayName;
{
    return [[self lastComponentOfFileName] stringByDeletingPathExtension];
}

- (MZTimeCode *)duration;
{
    return [data duration];
}

- (NSArray *)tags;
{
    if(!tags)
    {
        NSMutableArray* ret = [NSMutableArray array];
        for(MZTag* tag in [data providedTags])
        {
            [ret addObject:[MZTagItem itemWithTag:tag document:self]];
        }
        tags = [[NSArray alloc] initWithArray:ret];
    }
    return tags;
}

/*
- (id)scriptingValueForSpecifier:(id)specifier
{
    NSLog(@"Bla Bla: %@ %@ %@ %@ %@", specifier, [specifier key], [[specifier childSpecifier] key], [[specifier containerSpecifier] key]);
    id ret = [super scriptingValueForSpecifier:specifier];
    return ret;
}
*/

- (NSScriptObjectSpecifier *)objectSpecifier;
{
    NSScriptClassDescription *containerClassDesc = (NSScriptClassDescription *)
        [NSScriptClassDescription classDescriptionForClass:[MetaZApplication class]];// 1
    return [[[NSNameSpecifier alloc]
        initWithContainerClassDescription:containerClassDesc
        containerSpecifier:nil key:@"orderedDocuments"
        name:[self displayName]] autorelease];
}
/*
- (NSArray *)indicesOfObjectsByEvaluatingObjectSpecifier:(NSScriptObjectSpecifier *)specifier
{
    NSLog(@"Bla Bla: %@ %@ %@", [specifier key], [[specifier childSpecifier] key], [[specifier containerSpecifier] key]);
    return nil;
}
*/

@end
