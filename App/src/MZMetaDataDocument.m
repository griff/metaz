//
//  MZMetaDataDocument.m
//  MetaZ
//
//  Created by Brian Olsen on 15/07/12.
//  Copyright 2012 Maven-Group. All rights reserved.
//
#import "MZMetaDataDocument.h"
#import "MetaZApplication.h"
#import "MZMetaLoader.h"
#import "MZScriptingAdditions.h"
#import "MZScriptingEnums.h"

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
    return [document.data.pure valueForKey:tag.identifier];
}

- (void)setValue:(id)value
{
    [document.data setValue:value forKey:tag.identifier];
}

- (id)scriptValue
{
    id value = self.value;
    if(value)
    {
        if([tag isKindOfClass:[MZEnumTag class]] )
        {
            id eTag = tag;
            value = [[MZScriptingEnums scriptingEnumsForMainBundle]
                            enumValueForEnum:[eTag enumScriptName]
                                   withValue:value];
        }
        else
        {
            id specifier = [value objectSpecifier];
            if(specifier)
                value = specifier;
        }
    }
    return value;
}

- (void)setScriptValue:(id)value
{
    if([value isKindOfClass:[NSAppleEventDescriptor class]])
        value = [value objectValue];
    NSLog(@"Set Value %@ %@ %@", document.data, value, tag.identifier);
    self.value = value;
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

+ (void) initialize {
	[super initialize];
	static BOOL tooLate = NO;
	if( ! tooLate ) {
		[[NSScriptCoercionHandler sharedCoercionHandler] registerCoercer:[self class] selector:@selector( coerceMetaDataDocument:toString: ) toConvertFromClass:[MZMetaDataDocument class] toClass:[NSString class]];
		tooLate = YES;
	}
}

+ (id) coerceMetaDataDocument:(MZMetaDataDocument *) value toString:(Class) class
{
	return [value.data loadedFileName];
}

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

- (NSURL *)fileURL;
{
    return [NSURL fileURLWithPath:[data loadedFileName]];
}

- (NSString *)displayName;
{
    return [[[data loadedFileName] lastPathComponent] stringByDeletingPathExtension];
}

- (BOOL)isDocumentEdited;
{
    return [data changed];
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

- (id)handleCloseScriptCommand:(NSScriptCommand *)cmd;
{
    NSUInteger idx = [[MZMetaLoader sharedLoader].files indexOfObject:data];
    if(idx != NSNotFound)
        [[MZMetaLoader sharedLoader] removeFilesAtIndexes:[NSIndexSet indexSetWithIndex:idx]];
    return nil;
}

- (id)handleSaveScriptCommand:(NSScriptCommand *)cmd;
{
    return nil;
}


@end
