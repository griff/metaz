//
//  MZDateFormatter.m
//  MetaZ
//
//  Created by Brian Olsen on 08/08/11.
//  Copyright 2011 Maven-Group. All rights reserved.
//

#import "MZDateFormatter.h"


@implementation MZDateFormatter

- (NSDate *)dateFromString:(NSString *)string;
{
    return [super dateFromString:string];
}

- (NSString *)stringFromDate:(NSDate *)date;
{
    return [super stringFromDate:date];
}


- (BOOL)isPartialStringValid:(NSString **)partialStringPtr proposedSelectedRange:(NSRangePointer)proposedSelRangePtr originalString:(NSString *)origString originalSelectedRange:(NSRange)origSelRange errorDescription:(NSString **)error;
{
    BOOL ret = [super isPartialStringValid:partialStringPtr proposedSelectedRange:proposedSelRangePtr originalString:origString originalSelectedRange:origSelRange errorDescription:error];
    return ret;
}

- (BOOL)getObjectValue:(id *)obj forString:(NSString *)string errorDescription:(NSString **)error;
{
    if(!string || [string length]==0)
    {
        if(obj)
            *obj = nil;
        return YES;
    }
    BOOL ret = [super getObjectValue:obj forString:string errorDescription:error];
    return ret;
}

@end
