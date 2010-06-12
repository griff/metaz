//
//  MZTimedTextItem.m
//  MetaZ
//
//  Created by Brian Olsen on 09/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "MZTimedTextItem.h"
#import <MetaZKit/MZLogger.h>


NSString* fixText(NSString *newText)
{
    return [[newText
        componentsSeparatedByCharactersInSet:
            [NSCharacterSet whitespaceAndNewlineCharacterSet]]
        componentsJoinedByString:@" "];
}


@implementation MZTimedTextItem

+ (NSArray *)parseChapters:(NSString *)str duration:(MZTimeCode *)duration
{
    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([str characterAtIndex:0] == 'C') // Ogg format
        return [self parseOggChapters:str duration:duration];
    else if([[str substringToIndex:2] isEqual:@"1."]) // Web format
        return [self parseWebChapters:str duration:duration];
    else
        return [self parseMP4Chapters:str duration:duration];
}

+ (NSArray *)parseOggChapters:(NSString *)str duration:(MZTimeCode *)duration
{
    BOOL parsingTimestamp = YES;
    MZTimeCode* timestamp = nil;
    NSString* txt = nil;
    MZTimeCode* nextTimestamp = nil;

    NSMutableArray* ret = [NSMutableArray array];

    NSArray* lines = [str componentsSeparatedByString:@"\n"];
    for(NSString* line in lines)
    {
        line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if([line length] == 0)
            continue;
        
        NSScanner* sc = [NSScanner scannerWithString:line];
        [sc setCharactersToBeSkipped:nil];
        
        if(![sc scanUpToString:@"=" intoString:nil])
            return nil;
        if(![sc scanString:@"=" intoString:nil])
            return nil;

        NSString* newTxt = [line substringFromIndex:[sc scanLocation]];
        
        if(parsingTimestamp)
        {
            nextTimestamp = [MZTimeCode timeCodeWithString:newTxt];
            if(!nextTimestamp)
                return nil;
        }
        else
        {
            if(txt)
            {
                MZTimeCode* curDuration = [MZTimeCode timeCodeWithMillis:[nextTimestamp millis]-[timestamp millis]];
                [ret addObject:[MZTimedTextItem textItemWithStart:timestamp duration:curDuration text:txt]];
            }
            txt = newTxt;
            timestamp = nextTimestamp;
        }
        parsingTimestamp = !parsingTimestamp;
    }
    if(!parsingTimestamp)
        return nil;

    if(txt && timestamp)
    {
        if(duration)
            duration = [MZTimeCode timeCodeWithMillis:[duration millis]-[timestamp millis]];
        [ret addObject:[MZTimedTextItem textItemWithStart:timestamp duration:duration text:txt]];
    }
    if([ret count] == 0)
        return nil;
    return ret;
}

+ (NSArray *)parseMP4Chapters:(NSString *)str duration:(MZTimeCode *)duration
{
    MZTimeCode* timestamp = nil;
    NSString* txt = nil;

    NSMutableArray* ret = [NSMutableArray array];

    NSArray* lines = [str componentsSeparatedByString:@"\n"];
    for(NSString* line in lines)
    {
        line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if([line length] == 0)
            continue;
        
        NSScanner* sc = [NSScanner scannerWithString:line];
        [sc setCharactersToBeSkipped:nil];
        
        NSString* timestampText;
        if(![sc scanUpToCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:&timestampText])
            return nil;
        
        MZTimeCode* nextTimestamp = [MZTimeCode timeCodeWithString:timestampText];
        if(!nextTimestamp)
            return nil;
        
        if(![sc scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:nil])
            return nil;
            
        NSString* newTxt = [line substringFromIndex:[sc scanLocation]];
        if(txt)
        {
            MZTimeCode* curDuration = [MZTimeCode timeCodeWithMillis:[nextTimestamp millis]-[timestamp millis]];
            [ret addObject:[MZTimedTextItem textItemWithStart:timestamp duration:curDuration text:txt]];
        }
        timestamp = nextTimestamp;
        txt = newTxt;
    }
    
    if(txt && timestamp)
    {
        if(duration)
            duration = [MZTimeCode timeCodeWithMillis:[duration millis]-[timestamp millis]];
        [ret addObject:[MZTimedTextItem textItemWithStart:timestamp duration:duration text:txt]];
    }
    if([ret count] == 0)
        return nil;
    return ret;
}

+ (NSArray *)parseWebChapters:(NSString *)str duration:(MZTimeCode *)duration
{
    NSUInteger start = 0;

    NSMutableArray* ret = [NSMutableArray array];
    BOOL chapterNames = NO;

    NSArray* lines = [str componentsSeparatedByString:@"\n"];
    for(NSString* line in lines)
    {
        line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if([line length] == 0)
            continue;
        
        NSScanner* sc = [NSScanner scannerWithString:line];
        [sc setCharactersToBeSkipped:nil];
        
        if(![sc scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:nil])
            return nil;
        if(![sc scanString:@"." intoString:nil])
            return nil;
        if(![sc scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:nil])
            return nil;
        
        NSString* text;
        [sc scanUpToString:@"[" intoString:&text];
            
        if([sc isAtEnd] || chapterNames)
        {
            chapterNames = YES;
            [ret addObject:text];
            continue;
        }
        
        [sc scanString:@"[" intoString:nil];

        int minutes = 0;
        [sc scanInt:&minutes];
        if(![sc scanString:@":" intoString:nil])
        {
            chapterNames = YES;
            [ret addObject:text];
            continue;
        }

        int seconds;
        if(![sc scanInt:&seconds])
        {
            chapterNames = YES;
            [ret addObject:text];
            continue;
        }
        
        if(![sc scanString:@"]" intoString:nil])
        {
            chapterNames = YES;
            [ret addObject:text];
            continue;
        }
        
        NSUInteger millis = (minutes*60+seconds)*1000;
        
        [ret addObject:[MZTimedTextItem
            textItemWithStart:[MZTimeCode timeCodeWithMillis:start]
                     duration:[MZTimeCode timeCodeWithMillis:millis]
                         text:text]];
        start += millis;
    }
    if(chapterNames)
    {
        int count = [ret count];
        for(int i=0; i<count; i++)
        {
            id value = [ret objectAtIndex:i];
            if([value isKindOfClass:[MZTimedTextItem class]])
                [ret replaceObjectAtIndex:i withObject:[value text]];
        }
    }
    else if(duration && start != [duration millis])
    {
        MZLoggerError(@"Chapters don't match the expected duration %@ actual %@",
            duration, [MZTimeCode timeCodeWithMillis:start]);
    }

    return ret;
}

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

@synthesize start;
@synthesize duration;
@synthesize text;

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
