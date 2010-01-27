//
//  NSString+TempFile.m
//  MetaZ
//
//  Created by Brian Olsen on 19/01/10.
//  Copyright 2010 Maven-Group. All rights reserved.
//

#import "NSString+TempFile.h"


@implementation NSString (MZTempFile)

+ (id)temporaryPathWithFormat:(NSString *)format
{
    NSString* file = NSTemporaryDirectory();
    if(!file)
        file = @"/tmp";
        
    return [file stringByAppendingPathComponent:
        [NSString stringWithFormat:format,
            [[NSProcessInfo processInfo] globallyUniqueString]]];
}

@end
