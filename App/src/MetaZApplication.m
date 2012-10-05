//
//  NSApplication+MetaZApplication.m
//  MetaZ
//
//  Created by Brian Olsen on 14/07/12.
//  Copyright 2012 Maven-Group. All rights reserved.
//

#import "MetaZApplication.h"


@implementation MetaZApplication

- (NSNumber*) ready {
    return [NSNumber numberWithBool:YES];
}

- (id)handleOpenScriptCommand:(NSScriptCommand *)test;
{
    id direct = [test directParameter];
    NSLog(@"Handle open: %@ %X", direct, [[test commandDescription] appleEventCodeForArgumentWithName:@""]);
    if([direct isKindOfClass:[NSArray class]])
    {
        NSMutableArray *names = [NSMutableArray arrayWithCapacity:[direct count]];
        for(NSURL* url in direct)
            [names addObject:[url path]];
        [[self delegate] application:self openFiles:names];
    }
    else
    {
        [[self delegate] application:self openFile:[direct path]];
    }
    return nil;
}
    
@end
