//
//  APReadDataTask.m
//  MetaZ
//
//  Created by Brian Olsen on 19/01/10.
//  Copyright 2010 Maven-Group. All rights reserved.
//

#import "APReadDataTask.h"


@implementation APReadDataTask

+ (id)taskWithProvider:(APDataProvider*)provider fromFileName:(NSString *)fileName dictionary:(NSMutableDictionary *)tagdict
{
    return [[[[self class] alloc] initWithProvider:provider fromFileName:fileName dictionary:tagdict] autorelease];
}

- (id)initWithProvider:(APDataProvider*)theProvider fromFileName:(NSString *)theFileName dictionary:(NSMutableDictionary *)theTagdict
{
    self = [super init];
    if(self)
    {
        provider = [theProvider retain];
        fileName = [theFileName retain];
        tagdict = [theTagdict retain];
    }
    return self;
}

- (void)dealloc
{
    [provider release];
    [fileName release];
    [tagdict release];
    [super dealloc];
}

- (void)parseData
{
    [provider parseData:self.data withFileName:fileName dict:tagdict];
}

@end


@implementation APPictureReadDataTask

+ (id)taskWithDictionary:(NSMutableDictionary *)tagdict
{
    return [[[[self class] alloc] initWithDictionary:tagdict] autorelease];
}

- (id)initWithDictionary:(NSMutableDictionary *)theTagdict
{
    self = [super init];
    if(self)
    {
        tagdict = [theTagdict retain];
        file = [[NSString temporaryPathWithFormat:@"MetaZImage_%@"] retain];
    }
    return self;
}


- (void)dealloc
{
    [tagdict release];
    [file release];
    [super dealloc];
}

@synthesize file;

- (void)startOnMainThread
{
    if([tagdict objectForKey:MZPictureTagIdent])
        [super startOnMainThread];
    else
    {
        self.executing = NO;
        self.finished = YES;
    }
}

- (void)taskTerminatedWithStatus:(int)status
{
    if(status != 0 || [self isCancelled])
    {
        [self setErrorFromStatus:status];
        self.executing = NO;
        self.finished = YES;
        return;
    }

    NSString* artfile = [file stringByAppendingString:@"_artwork_1"];
        
    NSFileManager* mgr = [NSFileManager manager];
    BOOL isDir;
    if([mgr fileExistsAtPath:[artfile stringByAppendingString:@".png"] isDirectory:&isDir] && !isDir)
    {
        NSData* data = [NSData dataWithContentsOfFile:[artfile stringByAppendingString:@".png"]];
        [tagdict setObject:data forKey:MZPictureTagIdent];
        [mgr removeItemAtPath:[artfile stringByAppendingString:@".png"] error:NULL];
    }
    else if([mgr fileExistsAtPath:[artfile stringByAppendingString:@".jpg"] isDirectory:&isDir] && !isDir)
    {
        NSData* data = [NSData dataWithContentsOfFile:[artfile stringByAppendingString:@".jpg"]];
        [tagdict setObject:data forKey:MZPictureTagIdent];
        [mgr removeItemAtPath:[artfile stringByAppendingString:@".jpg"] error:NULL];
    }
    

    self.executing = NO;
    self.finished = YES;
}

@end


@implementation APChapterReadDataTask

+ (id)taskWithFileName:(NSString*)fileName dictionary:(NSMutableDictionary *)tagdict;
{
    return [[[[self class] alloc] initWithFileName:fileName dictionary:tagdict] autorelease];
}

- (id)initWithFileName:(NSString*)fileName dictionary:(NSMutableDictionary *)theTagdict;
{
    self = [super init];
    if(self)
    {
        [self setArguments:[NSArray arrayWithObjects:@"-l", fileName, nil]];
        tagdict = [theTagdict retain];
    }
    return self;
}

- (void)dealloc
{
    [tagdict release];
    [super dealloc];
}

- (void)parseData
{
    if(!tagdict)
        return;
        
    NSString* str = [[[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding] autorelease];
    
    NSRange f = [str rangeOfString:@"Duration "];
    NSString* movieDurationStr = [str substringWithRange:NSMakeRange(f.location+f.length, 12)];
    MZTimeCode* movieDuration = [MZTimeCode timeCodeWithString:movieDurationStr];
    [tagdict setObject:movieDuration forKey:MZDurationTagIdent];
    
    NSArray* lines = [str componentsSeparatedByString:@"\tChapter #"];
    if([lines count]>1)
    {
        NSMutableArray* chapters = [NSMutableArray array];
        int len = [lines count];
        for(int i=1; i<len; i++)
        {
            NSString* line = [[lines objectAtIndex:i]
                              stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            NSString* startStr = [line substringWithRange:NSMakeRange(6, 12)];
            NSString* durationStr = [line substringWithRange:NSMakeRange(21, 12)];
            NSString* name = [line substringWithRange:NSMakeRange(37, [line length]-38)];
            
            MZTimeCode* start = [MZTimeCode timeCodeWithString:startStr];
            MZTimeCode* duration = [MZTimeCode timeCodeWithString:durationStr];
            
            if(!start || !duration)
                break;
            
            MZTimedTextItem* item = [MZTimedTextItem textItemWithStart:start duration:duration text:name];
            [chapters addObject:item];
        }
        if([chapters count] == len-1)
            [tagdict setObject:chapters forKey:MZChaptersTagIdent];
    }
}

@end
