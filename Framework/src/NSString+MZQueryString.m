//
//  NSString+MZQueryString.m
//  MetaZ
//
//  Created by Brian Olsen on 16/12/11.
//  Copyright 2011 Maven-Group. All rights reserved.
//

#import "NSString+MZQueryString.h"


@implementation NSString (MZQueryString)

+ (NSString *)mz_queryStringForParameterDictionary:(NSDictionary *)theParameters;
{
    NSMutableDictionary* temp = [NSMutableDictionary dictionary];
    for(NSString* key in theParameters)
    {
        //CFStringRef keyStr = (CFStringRef)[key copy];
        CFStringRef encodedKey = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, 
                                                                        (CFStringRef)key,
                                                                        NULL, 
                                                                        (CFStringRef)@"!*'();:@&=+$,/?%#[]", 
                                                                        kCFStringEncodingUTF8);
        //CFStringRef value = (CFStringRef)[[parameters objectForKey:key] copy];
        // Escape even the "reserved" characters for URLs 
        // as defined in http://www.ietf.org/rfc/rfc2396.txt
        CFStringRef encodedValue = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, 
                                                                           (CFStringRef)[theParameters objectForKey:key],
                                                                           NULL, 
                                                                           (CFStringRef)@"!*'();:@&=+$,/?%#[]", 
                                                                           kCFStringEncodingUTF8);
        [temp setObject:(NSString*)encodedValue forKey:(NSString*)encodedKey];
        CFRelease(encodedValue);
        //CFRelease(value);
        CFRelease(encodedKey);
    }
    NSArray* paramNames = [[temp allKeys] sortedArrayUsingSelector:@selector(compare:)];
	NSMutableString *queryString = [NSMutableString string];
	int i, n = [paramNames count];
	for (i = 0; i < n; i++) {
		NSString *paramName = [paramNames objectAtIndex:i];
		[queryString appendFormat:@"%@=%@", paramName, [temp objectForKey:paramName]];
		if (i < n - 1) [queryString appendString:@"&"];
	}
	return queryString;
}

@end
