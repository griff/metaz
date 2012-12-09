//
//  MZScriptingEnums.m
//  MetaZ
//
//  Created by Brian Olsen on 01/11/12.
//  Copyright 2012 Maven-Group. All rights reserved.
//

#import "MZScriptingEnums.h"
#import "MZScriptingAdditions.h"

@implementation MZScriptingEnumerator

@synthesize name;
@synthesize code;
@synthesize description;
@synthesize objectValue;

+ (id)scriptingEnumeratorWithName:(NSString *)name code:(OSType)code description:(NSString *)description value:(id)value;
{
    return [[[self alloc] initWithName:name code:code description:description value:value] autorelease];
}

- (id)initWithName:(NSString *)aName code:(OSType)aCode description:(NSString *)aDescription value:(id)aValue;
{
    self = [super init];
    if(self)
    {
        name = [aName retain];
        code = aCode;
        description = [aDescription retain];
        objectValue = [aValue retain];
    }
    return self;
}

- (void)dealloc
{
    [name release];
    [description release];
    [objectValue release];
    [super dealloc];
}

- (NSAppleEventDescriptor *)scriptingAnyDescriptor;
{
    return [NSAppleEventDescriptor descriptorWithEnumCode:code];
}

@end


@interface MZScriptingEnums ()

+ (id)scriptingEnumsWithBundle:(NSBundle *)bundle;
- (id)initWithBundle:(NSBundle *)bundle;
- (void)load;

@end


@implementation MZScriptingEnums

+ (id)scriptingEnumsForMainBundle;
{
    return [MZScriptingEnums scriptingEnumsForBundle:[NSBundle mainBundle]];
}

static NSMutableDictionary *sharedScriptingEnums = nil;

+ (id)scriptingEnumsForBundle:(NSBundle *)bundle;
{
    MZScriptingEnums * ret;
    @synchronized(self)
    {
        if(!sharedScriptingEnums)
            sharedScriptingEnums = [[NSMutableDictionary alloc] init];
        ret = [sharedScriptingEnums objectForKey:[bundle bundleIdentifier]];
        if(!ret)
        {
            ret = [MZScriptingEnums scriptingEnumsWithBundle:bundle];
            [sharedScriptingEnums setObject:ret forKey:[bundle bundleIdentifier]];
            [ret load];
        }
    }
    return ret;
}

+ (id)scriptingEnumsWithBundle:(NSBundle *)bundle;
{
    return [[[self alloc] initWithBundle:bundle] autorelease];
}

- (id)initWithBundle:(NSBundle *)aBundle;
{
    self = [super init];
    if(self)
    {
        bundle = [aBundle retain];
    }
    return self;
}

- (void)dealloc
{
    [bundle release];
    [codeToEnumValue release];
    [nameToEnum release];
    [super dealloc];
}

- (void)load
{
    NSString* file = [bundle objectForInfoDictionaryKey:@"OSAScriptingDefinition"];
    file = [NSString pathWithComponents:[NSArray arrayWithObjects:[bundle resourcePath], file, nil]];
    NSURL* url = [NSURL fileURLWithPath:file];
    NSError* error = nil;
    
    NSMutableDictionary* codes = [NSMutableDictionary dictionary];
    NSMutableDictionary* enums = [NSMutableDictionary dictionary];
    
    NSXMLDocument* doc = [[NSXMLDocument alloc] initWithContentsOfURL:url options:0 error:&error];
    NSArray* enumerations = [doc nodesForXPath:@"//enumeration" error:&error];
    for(NSXMLElement* enumeration in enumerations)
    {
        NSString* enumerationName = [[enumeration attributeForName:@"name"] stringValue];
        NSMutableDictionary* values = [NSMutableDictionary dictionary];
        NSArray* enumerators = [enumeration nodesForXPath:@"enumerator" error:&error];
        for(NSXMLElement* enumerator in enumerators)
        {
            NSString* name = [[enumerator attributeForName:@"name"] stringValue];
            NSString* codeStr = [[enumerator attributeForName:@"code"] stringValue];

            OSType code = '    ';
            const char* codeCStr = [codeStr cStringUsingEncoding:NSASCIIStringEncoding];
            NSUInteger l = [codeStr length];
            if(l>0)
            {
                code = (((OSType)codeCStr[0]) << 24);
                if(l>1)
                    code = code | (((OSType)codeCStr[1]) << 16);
                if(l>2)
                    code = code | (((OSType)codeCStr[2]) << 8);
                if(l>3)
                    code = code | ((OSType)codeCStr[3]);
            }
            
            NSString* description = [[enumerator attributeForName:@"description"] stringValue];

            id objectValue = nil;
            NSXMLElement* cocoa = [[enumerator nodesForXPath:@"cocoa" error:&error] lastObject];
            if(cocoa)
            {
                NSString* boolStr = [[cocoa attributeForName:@"boolean-value"] stringValue];
                if(boolStr)
                {
                    if([boolStr caseInsensitiveCompare:@"YES"] == NSOrderedSame)
                        objectValue = [NSNumber numberWithBool:YES];
                    else
                        objectValue = [NSNumber numberWithBool:NO];
                }
                
                if(!objectValue)
                {
                    NSString* strValue = [[cocoa attributeForName:@"string-value"] stringValue];
                    if(strValue)
                        objectValue = strValue;
                }
                
                if(!objectValue)
                {
                    NSString* strValue = [[cocoa attributeForName:@"integer-value"] stringValue];
                    if(strValue)
                        objectValue = [NSNumber numberWithInteger:[strValue integerValue]];
                }
            }
            if(!objectValue)
                objectValue = [NSValue valueWithFourCharCode:code];
                
            MZScriptingEnumerator* actual = 
                [MZScriptingEnumerator scriptingEnumeratorWithName:name
                                                              code:code
                                                       description:description
                                                             value:objectValue];
            [codes setObject:actual forKey:[NSValue valueWithFourCharCode:code]];
            [values setObject:actual forKey:objectValue];
        }
        [enums setObject:[NSDictionary dictionaryWithDictionary:values] forKey:enumerationName]; 
    }
    [doc release];
    
    codeToEnumValue = [[NSDictionary alloc] initWithDictionary:codes];
    nameToEnum = [[NSDictionary alloc] initWithDictionary:enums];
}

- (MZScriptingEnumerator *)enumValueWithCode:(OSType)code;
{
    return [codeToEnumValue objectForKey:[NSValue valueWithFourCharCode:code]];
}

- (MZScriptingEnumerator *)enumValueForEnum:(NSString *)name withValue:(id)value;
{
    return [[nameToEnum objectForKey:name] objectForKey:value];
}

- (NSArray *)valuesForEnum:(NSString *)name;
{
    NSDictionary* theEnum = [nameToEnum objectForKey:name];
    if(!theEnum)
        return nil;
    return [theEnum allValues];
}

- (NSArray *)names;
{
    return [nameToEnum allKeys];
}

@end
