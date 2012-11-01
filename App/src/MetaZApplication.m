//
//  NSApplication+MetaZApplication.m
//  MetaZ
//
//  Created by Brian Olsen on 14/07/12.
//  Copyright 2012 Maven-Group. All rights reserved.
//

#import "MetaZApplication.h"
#import "MZSelectedMetaDataDocument.h"
#import "MZMetaLoader.h"

@implementation MetaZApplication
@synthesize filesController;

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

- (id)selection;
{
    return [self selectedDocuments];
}

- (void)setSelection:(id)sel;
{
    [self setSelectedDocuments:sel];
}

- (void)setSelectedDocuments:(id)sel
{
    if([sel isKindOfClass:[NSArray class]])
        sel = [sel arrayByPerformingSelector:@selector(data)];
    else
        sel = [NSArray arrayWithObject:[sel data]];
    [filesController setSelectedObjects:sel];
}

- (id)selectedDocuments;
{
    NSArray* sel = [filesController selectedObjects];
    if([sel count]==0)
        return nil;
    if([sel count]==1)
        return [MZSelectedMetaDataDocument documentWithEdit:[sel objectAtIndex:0]];
    
    NSMutableArray* arr = [NSMutableArray array];
    for(MetaEdits* edit in sel)
        [arr addObject:[MZSelectedMetaDataDocument documentWithEdit:edit]];
    return arr;
}

- (NSArray *)orderedDocuments
{
    if(!documents)
        documents = [[NSMutableArray alloc] init];
    [documents removeAllObjects];
    
    NSArray* files = [MZMetaLoader sharedLoader].files;
    for(MetaEdits* edit in files)
    {
        [documents addObject:[MZMetaDataDocument documentWithEdit:edit]];
    }
    return documents;
}

@end
