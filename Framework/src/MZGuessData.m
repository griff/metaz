//
//  MZGuessData.m
//  MetaZ
//
//  Created by Brian Olsen on 31/10/10.
//  Copyright 2010 Maven-Group. All rights reserved.
//

#import "MZGuessData.h"


@implementation MZGuessData

-(void)guessTitle
{
    NSString* basefile = [fileName lastPathComponent];
    NSString* newTitle = [basefile substringToIndex:[basefile length] - [[basefile pathExtension] length] - 1];
    newTitle = [newTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([newTitle hasSuffix:@"]"])
    {
        NSInteger len = [newTitle length];
        NSScanner* scanner = [NSScanner scannerWithString:newTitle];
        [scanner setCharactersToBeSkipped:nil];
        [scanner setScanLocation:len-6];
        NSString* temp;
        if([scanner scanString:@"[" intoString:&temp])
        {
            if([scanner scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&temp])
            {
                if([scanner scanString:@"]" intoString:&temp] && [scanner scanLocation]==len)
                    newTitle = [newTitle substringToIndex:len-6];
            }
        }
    }
    else if([newTitle hasSuffix:@")"])
    {
        NSInteger len = [newTitle length];
        NSScanner* scanner = [NSScanner scannerWithString:newTitle];
        [scanner setCharactersToBeSkipped:nil];
        [scanner setScanLocation:len-6];
        NSString* temp;
        if([scanner scanString:@"(" intoString:&temp])
        {
            if([scanner scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&temp])
            {
                if([scanner scanString:@")" intoString:&temp] && [scanner scanLocation]==len)
                    newTitle = [newTitle substringToIndex:len-6];
            }
        }
    }
    newTitle = [newTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return newTitle;
}

@end
