//
//  MZTimedTextItem.m
//  MetaZ
//
//  Created by Brian Olsen on 09/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "MZTimedTextItem.h"


NSString* fixText(NSString *newText)
{
    return [[newText
        componentsSeparatedByCharactersInSet:
            [NSCharacterSet whitespaceAndNewlineCharacterSet]]
        componentsJoinedByString:@" "];
}


@implementation MZTimedTextItem
@synthesize start;
@synthesize duration;

+ (id)textItemWithStart:(MZTimeCode *)start duration:(MZTimeCode *)duration text:(NSString *)text
{
    return [[[self alloc] initWithStart:start duration:duration text:text] autorelease];
}

- (id)initWithStart:(MZTimeCode *)aStart duration:(MZTimeCode *)aDuration text:(NSString *)aText
{
    self = [super init];
    if(self)
    {
        start = [aStart retain];
        duration = [aDuration retain];
        text = [fixText(aText) retain];
    }
    return self;
}

- (void)dealloc
{
    [start release];
    [duration release];
    [text release];
    [super dealloc];
}

- (NSString *)text
{
    return text;
}

- (NSString *)description
{
    return [NSString
        stringWithFormat:@"%@ %@",
            [start description],
            text];
}

#pragma mark - NSCoding implementation
- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if(self)
    {
        start = [[decoder decodeObjectForKey:@"start"] retain];
        duration = [[decoder decodeObjectForKey:@"duration"] retain];
        text = [[decoder decodeObjectForKey:@"text"] retain];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:start forKey:@"start"];
    [encoder encodeObject:duration forKey:@"duration"];
    [encoder encodeObject:text forKey:@"text"];
}

#pragma mark - NSCopying implementation
- (id)copyWithZone:(NSZone *)zone
{
    return [[MZTimedTextItem allocWithZone:zone]
        initWithStart:[start copyWithZone:zone]
             duration:[duration copyWithZone:zone]
                 text:[text copyWithZone:zone]];
}

#pragma mark - NSMutableCopying implementation
- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [[MZMutableTimedTextItem allocWithZone:zone]
        initWithStart:start
             duration:duration
                 text:text];
}

@end


@implementation MZMutableTimedTextItem

- (void)setText:(NSString *)aText
{
    text = [fixText(aText) retain];
}

@end
