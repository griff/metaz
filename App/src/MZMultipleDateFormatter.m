//
//  MZMultipleDateFormatter.m
//  MetaZ
//
//  Created by Brian Olsen on 20/12/11.
//  Copyright 2011 Maven-Group. All rights reserved.
//

#import "MZMultipleDateFormatter.h"


@implementation MZMultipleDateFormatter

- (id)init;
{
    self = [super init];
    if(self) {
        utc = [[NSDateFormatter alloc] init];
        utc.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
        utc.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
        iso8601 = [[NSDateFormatter alloc] init];
        iso8601.dateFormat = @"yyyy-MM-dd";
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        utc = [[NSDateFormatter alloc] init];
        utc.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
        utc.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
        iso8601 = [[NSDateFormatter alloc] init];
        iso8601.dateFormat = @"yyyy-MM-dd";
    }
    return self;
}

- (void)dealloc
{
    [utc release];
    [iso8601 release];
    [super dealloc];
}

- (BOOL)getObjectValue:(id *)obj forString:(NSString *)string errorDescription:(NSString **)error;
{
    if(!string || [string length]==0)
    {
        if(obj)
            *obj = nil;
        return YES;
    }
    NSDate* date = [utc dateFromString:string];
    if(!date)
        date = [iso8601 dateFromString:string];
    if(date)
    {
        if(obj)
            *obj = date;
        return YES;
    }
    BOOL ret = [super getObjectValue:obj forString:string errorDescription:error];
    return ret;
}

@end
