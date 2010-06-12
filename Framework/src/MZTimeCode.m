//
//  MZTimeCode.m
//  MetaZ
//
//  Created by Brian Olsen on 09/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "MZTimeCode.h"


@implementation MZTimeCode
@synthesize millis;

+ (id)timeCodeWithString:(NSString *)str
{
    return [[[self alloc] initWithString:str] autorelease];
}

+ (id)timeCodeWithMillis:(NSUInteger)millis
{
    return [[[self alloc] initWithMillis:millis] autorelease];
}

- (id)initWithString:(NSString *)str
{
    NSScanner* scanner = [NSScanner scannerWithString:str];
    NSUInteger theMillis = 0;
    NSInteger value;
    if(![scanner scanInteger:&value])
    {
        [self release];
        return nil;
    }
    theMillis += value*3600000; // Hours

    NSCharacterSet* sepSet = [NSCharacterSet characterSetWithCharactersInString:@";.:"];

    if(![scanner scanCharactersFromSet:sepSet intoString:NULL])
    {
        [self release];
        return nil;
    }

    if(![scanner scanInteger:&value])
    {
        [self release];
        return nil;
    }
    theMillis += value*60000; // Minutes

    if(![scanner scanCharactersFromSet:sepSet intoString:NULL])
    {
        [self release];
        return nil;
    }

    if(![scanner scanInteger:&value])
    {
        [self release];
        return nil;
    }
    theMillis += value*1000; // Seconds
    
    if(![scanner scanCharactersFromSet:sepSet intoString:NULL])
    {
        [self release];
        return nil;
    }

    if(![scanner scanInteger:&value])
    {
        [self release];
        return nil;
    }
    theMillis += value; // milliseconds
    return [self initWithMillis:theMillis];
}

- (id)initWithMillis:(NSUInteger)theMillis
{
    self = [super init];
    if(self)
        millis = theMillis;
    return self;
}

- (NSUInteger)ms
{
    return self.millis % 1000;
}

- (NSUInteger)sec
{
    return (self.millis / 1000) % 60;
}

- (NSUInteger)min
{
    return (self.millis / 60000) % 60;
}

- (NSUInteger)hour
{
    return self.millis / 3600000;
}

- (MZTimeCode *)addMillis:(NSUInteger)theMillis
{
    return [MZTimeCode timeCodeWithMillis:millis + theMillis];
}

- (MZTimeCode *)addTimeCode:(MZTimeCode *)timeCode
{
    return [MZTimeCode timeCodeWithMillis:millis + [timeCode millis]];
}

- (NSString *)description
{
    return [self stringValue];
}

- (NSString *)stringValue
{
    return [NSString stringWithFormat:@"%02u:%02u:%02u.%03u",
        [self hour], [self min], [self sec], [self ms]];
}

- (BOOL)isEqual:(id)object
{
    if(![object isKindOfClass:[MZTimeCode class]])
        return NO;
    MZTimeCode* other = object;
    return millis == other->millis;
}

- (NSComparisonResult)compare:(MZTimeCode *)aTimeCode
{
    if(self->millis < aTimeCode->millis)
        return NSOrderedAscending;
    if(self->millis > aTimeCode->millis)
        return NSOrderedDescending;
    return NSOrderedSame;
}

#pragma mark - NSCoding implementation
- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if(self)
    {
        millis = [decoder decodeIntegerForKey:@"millis"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeInteger:millis forKey:@"millis"];
}

#pragma mark - NSCopying implementation
- (id)copyWithZone:(NSZone *)zone
{
    return [[[self class] allocWithZone:zone] initWithMillis:millis];
}

@end
