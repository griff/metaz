//
//  MZGuessData.m
//  MetaZ
//
//  Created by Brian Olsen on 31/10/10.
//  Copyright 2010 Maven-Group. All rights reserved.
//

#import "MZGuessData.h"


@implementation MZGuessData

- (id)init
{
    # DVD Episode Support - DddEee
    @"^(?:(?<name>.*?)[\/\s._-]+)?(?:d|dvd|disc|disk)[\s._]?(?<dvd>\d{1,2})[x\/\s._-]*(?:e|ep|episode)[\s._]?(?<episode>\d{1,2}(?:\.\d{1,2})?)(?:-?(?:(?:e|ep)[\s._]*)?(?<endep>\d{1,2}))?(?:[\s._]?(?:p|part)[\s._]?(?<part>\d+))?(?<subep>[a-z])?(?:[\/\s._-]*(?<epname>[^\/]+?))?$'";
    
    # TV Show Support - SssEee or Season_ss_Episode_ss
    @"^(?:(?<name>.*?)[\/\s._-]+)?(?:s|se|season|series)[\s._-]?(?<season>\d{1,2})[x\/\s._-]*(?:e|ep|episode|[\/\s._-]+)[\s._-]?(?<episode>\d{1,2})(?:-?(?:(?:e|ep)[\s._]*)?(?<endep>\d{1,2}))?(?:[\s._]?(?:p|part)[\s._]?(?<part>\d+))?(?<subep>[a-z])?(?:[\/\s._-]*(?<epname>[^\/]+?))?$";
    
    # Movie IMDB Support
    @"^(?<movie>.*?)?(?:[\/\s._-]*(?<openb>\[)?(?<year>(?:19|20)\d{2})(?(<openb>)\]))?(?:[\/\s._-]*(?<openc>\[)?(?:(?:imdb|tt)[\s._-]*)*(?<imdb>\d{7})(?(<openc>)\]))(?:[\s._-]*(?<title>[^\/]+?))?$";
    
    # Movie + Year Support
    @"^(?:(?<movie>.*?)[\/\s._-]*)?(?<openb>\[)?(?<year>(?:19|20)\d{2})(?(<openb>)\])(?:[\s._-]*(?<title>[^\/]+?))?$";
    
    # TV Show Support - see
    @"^(?:(?<name>.*?)[\/\s._-]*)?(?<season>\d{1,2}?)(?<episode>\d{2})(?:[\s._-]*(?<epname>.+?))?$";
    
    # TV Show Support - sxee
    @"^(?:(?<name>.*?)[\/\s._-]*)?(?<openb>\[)?(?<season>\d{1,2})[x\/](?<episode>\d{1,2})(?:-(?:\k<season>x)?(?<endep>\d{1,2}))?(?(<openb>)\])(?:[\s._-]*(?<epname>[^\/]+?))?$";
    
    # TV Show Support - season only
    @"^(?:(?<name>.*?)[\/\s._-]+)?(?:s|se|season|series)[\s._]?(?<season>\d{1,2})(?:[\/\s._-]*(?<epname>[^\/]+?))?$";
    
    # TV Show Support - episode only
    @"^(?:(?<name>.*?)[\/\s._-]*)?(?:(?:e|ep|episode)[\s._]?)?(?<episode>\d{1,2})(?:-(?:e|ep)?(?<endep>\d{1,2}))?(?:(?:p|part)(?<part>\d+))?(?<subep>[a-z])?(?:[\/\s._-]*(?<epname>[^\/]+?))?$";
    
    # Default Movie Support
    @"^(?<movie>.*)$";
}

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
