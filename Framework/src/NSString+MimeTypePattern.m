//
//  NSString+MimeTypePattern.m
//  MetaZ
//
//  Created by Brian Olsen on 08/12/12.
//  Copyright 2012 Maven-Group. All rights reserved.
//

#import "NSString+MimeTypePattern.h"

/*
{
    [@"testtype/mcTest" matchesMimeTypePattern:@"*"];
    [@"testtype/mcTest" matchesMimeTypePattern:@"testtype/*"];
    [@"testtype/mcTest" matchesMimeTypePattern:@"testtype/mcTest"];
    [@"testtype/mcTest" matchesMimeTypePattern:@"TESTTYPE/*"];
    [@"testtype/mcTest" matchesMimeTypePattern:@"TESTTYPE/mctest"];
    ![@"testtype/mcTest" matchesMimeTypePattern:@"testtyp/*"];
    ![@"testtype/mcTest" matchesMimeTypePattern:@"testtype/mTest"];
}
*/

@implementation NSString (MimeTypePattern)

- (BOOL)matchesMimeTypePattern:(NSString *)pattern;
{
    if([pattern isEqualToString:@"*"])
        return YES;
    
    NSRange range = NSMakeRange(0, [self length]);
    NSUInteger length = [pattern length];
    if([pattern hasSuffix:@"/*"])
    {
        length = length-1;
        pattern = [pattern substringToIndex:length];
        if(length<range.length)
            range.length = length;
    } else if(range.length != length)
        return NO;
        
    NSComparisonResult res = [self compare:pattern options:NSCaseInsensitiveSearch | NSLiteralSearch range:range];
    return res == NSOrderedSame;
}

@end
