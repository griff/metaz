//
//  MZYearDateFormatter.m
//  MetaZ
//
//  Created by Brian Olsen on 08/08/11.
//  Copyright 2011 Maven-Group. All rights reserved.
//

#import "MZYearDateFormatter.h"


@implementation MZYearDateFormatter

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self) {
        dateFormatter = [[MZMultipleDateFormatter alloc] initWithCoder:aDecoder];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [dateFormatter encodeWithCoder:aCoder];
}


- (id)init;
{
    self = [super init];
    if(self) {
        dateFormatter = [[MZMultipleDateFormatter alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [dateFormatter release];
    [super dealloc];
}

- (NSString *)stringForObjectValue:(id)obj;
{
    if([obj isKindOfClass:[NSNumber class]])
        return [obj stringValue];
    NSString* ret = [dateFormatter stringForObjectValue:obj];
    return ret;
}

- (NSAttributedString *)attributedStringForObjectValue:(id)obj withDefaultAttributes:(NSDictionary *)attrs;
{
    return nil;
}

- (NSString *)editingStringForObjectValue:(id)obj;
{
    return [self stringForObjectValue:obj];
    /*NSString* ret = [dateFormatter editingStringForObjectValue:obj];
    return ret;*/
}


- (BOOL)getObjectValue:(id *)obj forString:(NSString *)string errorDescription:(NSString **)error;
{
    if(!string || [string length]==0)
    {
        if(obj)
            *obj = nil;
        return YES;
    }

    if([string mz_allInCharacterSet:[NSCharacterSet decimalDigitCharacterSet]])
    {
        if(obj)
            *obj = [NSNumber numberWithInt:[string intValue]];
        return YES;
    }
    return [dateFormatter getObjectValue:obj forString:string errorDescription:error];
}

#pragma mark NSDateFormatter

- (NSString *)dateFormat;
{
    return [dateFormatter dateFormat];
}

#if MAC_OS_X_VERSION_10_4 <= MAC_OS_X_VERSION_MAX_ALLOWED

- (NSDateFormatterStyle)dateStyle;
{
    return [dateFormatter dateStyle];
}

- (void)setDateStyle:(NSDateFormatterStyle)style;
{
    [dateFormatter setDateStyle:style];
}

- (NSDateFormatterStyle)timeStyle;
{
    return [dateFormatter timeStyle];
}

- (void)setTimeStyle:(NSDateFormatterStyle)style;
{
    [dateFormatter setTimeStyle:style];
}

- (NSLocale *)locale;
{
    return [dateFormatter locale];
}

- (void)setLocale:(NSLocale *)locale;
{
    [dateFormatter setLocale:locale];
}

- (BOOL)generatesCalendarDates;
{
    return [dateFormatter generatesCalendarDates];
}

- (void)setGeneratesCalendarDates:(BOOL)b;
{
    [dateFormatter setGeneratesCalendarDates:b];
}

- (NSDateFormatterBehavior)formatterBehavior;
{
    return [dateFormatter formatterBehavior];
}

- (void)setFormatterBehavior:(NSDateFormatterBehavior)behavior;
{
    [dateFormatter setFormatterBehavior:behavior];
}

- (void)setDateFormat:(NSString *)string;
{
    [dateFormatter setDateFormat:string];
}

- (NSTimeZone *)timeZone;
{
    return [dateFormatter timeZone];
}

- (void)setTimeZone:(NSTimeZone *)tz;
{
    [dateFormatter setTimeZone:tz];
}

- (NSCalendar *)calendar;
{
    return [dateFormatter calendar];
}

- (void)setCalendar:(NSCalendar *)calendar;
{
    [dateFormatter setCalendar:calendar];
}

- (BOOL)isLenient;
{
    return [dateFormatter isLenient];
}

- (void)setLenient:(BOOL)b;
{
    [dateFormatter setLenient:b];
}

- (NSDate *)twoDigitStartDate;
{
    return [dateFormatter twoDigitStartDate];
}

- (void)setTwoDigitStartDate:(NSDate *)date;
{
    [dateFormatter setTwoDigitStartDate:date];
}

- (NSDate *)defaultDate;
{
    return [dateFormatter defaultDate];
}

- (void)setDefaultDate:(NSDate *)date;
{
    [dateFormatter setDefaultDate:date];
}

- (NSArray *)eraSymbols;
{
    return [dateFormatter eraSymbols];
}

- (void)setEraSymbols:(NSArray *)array;
{
    [dateFormatter setEraSymbols:array];
}

- (NSArray *)monthSymbols;
{
    return [dateFormatter monthSymbols];
}

- (void)setMonthSymbols:(NSArray *)array;
{
    [dateFormatter setMonthSymbols:array];
}

- (NSArray *)shortMonthSymbols;
{
    return [dateFormatter shortMonthSymbols];
}

- (void)setShortMonthSymbols:(NSArray *)array;
{
    [dateFormatter setShortMonthSymbols:array];
}

- (NSArray *)weekdaySymbols;
{
    return [dateFormatter weekdaySymbols];
}

- (void)setWeekdaySymbols:(NSArray *)array;
{
    [dateFormatter setWeekdaySymbols:array];
}

- (NSArray *)shortWeekdaySymbols;
{
    return [dateFormatter shortWeekdaySymbols];
}

- (void)setShortWeekdaySymbols:(NSArray *)array;
{
    [dateFormatter setShortWeekdaySymbols:array];
}

- (NSString *)AMSymbol;
{
    return [dateFormatter AMSymbol];
}

- (void)setAMSymbol:(NSString *)string;
{
    [dateFormatter setAMSymbol:string];
}

- (NSString *)PMSymbol;
{
    return [dateFormatter PMSymbol];
}

- (void)setPMSymbol:(NSString *)string;
{
    [dateFormatter setPMSymbol:string];
}

#endif

#if MAC_OS_X_VERSION_10_5 <= MAC_OS_X_VERSION_MAX_ALLOWED

- (NSArray *)longEraSymbols;
{
    return [dateFormatter longEraSymbols];
}

- (void)setLongEraSymbols:(NSArray *)array;
{
    [dateFormatter setLongEraSymbols:array];
}

- (NSArray *)veryShortMonthSymbols;
{
    return [dateFormatter veryShortMonthSymbols];
}

- (void)setVeryShortMonthSymbols:(NSArray *)array;
{
    [dateFormatter setVeryShortMonthSymbols:array];
}

- (NSArray *)standaloneMonthSymbols;
{
    return [dateFormatter standaloneMonthSymbols];
}

- (void)setStandaloneMonthSymbols:(NSArray *)array;
{
    [dateFormatter setStandaloneMonthSymbols:array];
}

- (NSArray *)shortStandaloneMonthSymbols;
{
    return [dateFormatter shortStandaloneMonthSymbols];
}

- (void)setShortStandaloneMonthSymbols:(NSArray *)array;
{
    [dateFormatter setShortStandaloneMonthSymbols:array];
}

- (NSArray *)veryShortStandaloneMonthSymbols;
{
    return [dateFormatter veryShortStandaloneMonthSymbols];
}

- (void)setVeryShortStandaloneMonthSymbols:(NSArray *)array;
{
    [dateFormatter setVeryShortStandaloneMonthSymbols:array];
}

- (NSArray *)veryShortWeekdaySymbols;
{
    return [dateFormatter veryShortWeekdaySymbols];
}

- (void)setVeryShortWeekdaySymbols:(NSArray *)array;
{
    [dateFormatter setVeryShortWeekdaySymbols:array];
}

- (NSArray *)standaloneWeekdaySymbols;
{
    return [dateFormatter standaloneWeekdaySymbols];
}

- (void)setStandaloneWeekdaySymbols:(NSArray *)array;
{
    [dateFormatter setStandaloneWeekdaySymbols:array];
}

- (NSArray *)shortStandaloneWeekdaySymbols;
{
    return [dateFormatter shortStandaloneWeekdaySymbols];
}

- (void)setShortStandaloneWeekdaySymbols:(NSArray *)array;
{
    [dateFormatter setShortStandaloneWeekdaySymbols:array];
}

- (NSArray *)veryShortStandaloneWeekdaySymbols;
{
    return [dateFormatter veryShortStandaloneWeekdaySymbols];
}

- (void)setVeryShortStandaloneWeekdaySymbols:(NSArray *)array;
{
    [dateFormatter setVeryShortStandaloneWeekdaySymbols:array];
}

- (NSArray *)quarterSymbols;
{
    return [dateFormatter quarterSymbols];
}

- (void)setQuarterSymbols:(NSArray *)array;
{
    [dateFormatter setQuarterSymbols:array];
}

- (NSArray *)shortQuarterSymbols;
{
    return [dateFormatter shortQuarterSymbols];
}

- (void)setShortQuarterSymbols:(NSArray *)array;
{
    [dateFormatter setShortQuarterSymbols:array];
}

- (NSArray *)standaloneQuarterSymbols;
{
    return [dateFormatter standaloneQuarterSymbols];
}

- (void)setStandaloneQuarterSymbols:(NSArray *)array;
{
    [dateFormatter setStandaloneQuarterSymbols:array];
}

- (NSArray *)shortStandaloneQuarterSymbols;
{
    return [dateFormatter shortStandaloneQuarterSymbols];
}

- (void)setShortStandaloneQuarterSymbols:(NSArray *)array;
{
    [dateFormatter setShortStandaloneQuarterSymbols:array];
}

- (NSDate *)gregorianStartDate;
{
    return [dateFormatter gregorianStartDate];
}

- (void)setGregorianStartDate:(NSDate *)date;
{
    [dateFormatter setGregorianStartDate:date];
}
#endif

@end
