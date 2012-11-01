//
//  NSApplication+MetaZApplication.m
//  MetaZ
//
//  Created by Brian Olsen on 14/07/12.
//  Copyright 2012 Maven-Group. All rights reserved.
//

#import "MetaZApplication.h"
#import "MZMetaLoader.h"

@implementation MetaZApplication

- (NSNumber*) ready {
    return [NSNumber numberWithBool:YES];
}

- (id)handleOpenScriptCommand:(NSScriptCommand *)test;
{
    id direct = [test directParameter];
    NSLog(@"Handle open: %@ %@", direct, [test evaluatedArguments]);
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
        NSArray* files = [MZMetaLoader sharedLoader].files;
        for(MetaEdits* edit in files)
        {
            if([[edit loadedFileName] isEqualToString:[direct path]])
            {
                return [MZMetaDataDocument documentWithEdit:edit];
            }
        }
    }
    return nil;
}
    
@end
