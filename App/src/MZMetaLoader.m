//
//  MetaLoader.m
//  MetaZ
//
//  Created by Brian Olsen on 25/08/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "MZMetaLoader.h"

@implementation MZMetaLoader
@synthesize files;

#pragma mark - initialization 

static MZMetaLoader* sharedLoader = nil;

+(MZMetaLoader *)sharedLoader {
    if(!sharedLoader)
        [[[MZMetaLoader alloc] init] release];
    return sharedLoader;
}

-(id)init {
    self = [super init];

    if(sharedLoader)
    {
        [self release];
        self = [sharedLoader retain];
    } else if(self)
    {
        files = [[NSMutableArray alloc] init];
        sharedLoader = [self retain];
    }
    return self;
}

-(void)dealloc {
    [files release];
    [super dealloc];
}


-(NSArray *)types {
    return [[MZPluginController sharedInstance] dataProviderTypes];
}

-(void)removeAllObjects
{
    [self willChangeValueForKey:@"files"];
    [files removeAllObjects];
    [self didChangeValueForKey:@"files"];
}


-(void)loadFromFile:(NSString *)fileName
{
    [self loadFromFile:fileName toIndex:[files count]];
}

-(void)loadFromFiles:(NSArray *)fileNames
{
    [self loadFromFiles:fileNames toIndex:[files count]];
}

- (void)loadFromFile:(NSString *)fileName toIndex:(NSUInteger)index
{
    NSAssert(fileName, @"Provided fileName");
    [self loadFromFiles:[NSArray arrayWithObject:fileName] toIndex:index];
}

- (void)loadFromFiles:(NSArray *)fileNames toIndex:(NSUInteger)index
{
    NSAssert(fileNames, @"Provided filenames");
    if([fileNames count]==0)
        return;
    [self loadFromFiles:fileNames
              toIndexes:[NSIndexSet indexSetWithIndexesInRange:
                    NSMakeRange(index, [fileNames count])]];
}

- (void)loadFromFiles:(NSArray *)fileNames toIndexes:(NSIndexSet*)indexes
{
    NSAssert(fileNames, @"Provided filenames");
    if([fileNames count]==0)
        return;
    NSAssert([fileNames count]==[indexes count], @"Count of indexes and filenames");

    [self willChangeValueForKey:@"files"];
    NSMutableArray* arr = [NSMutableArray arrayWithCapacity:[fileNames count]];
    for ( NSString* fileName in fileNames )
    {
        //NSLog(@"Loading file '%@'", fileName);
        MetaEdits* edits = [[MZPluginController sharedInstance] loadDataFromFile:fileName];
        if(edits)
            [arr addObject:edits];
        else
            NSLog(@"Could no load file '%@'", fileName);
    }
    [files insertObjects:arr atIndexes:indexes];
    [self didChangeValueForKey:@"files"];
}

- (void)moveObjects:(NSArray *)objects toIndex:(NSUInteger)index
{
    [self willChangeValueForKey:@"files"];
    NSMutableIndexSet* idx = [[[NSMutableIndexSet alloc] init] autorelease];
    for(MetaEdits* edit in objects)
    {
        for(int i=[files count]-1; i>=0; i--)
        {
            MetaEdits* ob = [files objectAtIndex:i];
            if(ob == edit)
                [idx addIndex:i];
        }
    }
    [files removeObjectsAtIndexes:idx];

    index -= [idx countOfIndexesInRange:NSMakeRange(0, index)];
    for(int i=[objects count]-1; i>=0; i--)
    {
        [files insertObject:[objects objectAtIndex:i] atIndex:index];
    }
    [self didChangeValueForKey:@"files"];
}

- (void)reloadEdits:(MetaEdits *)edits
{
    [self willChangeValueForKey:@"files"];
    [files addObject:edits];
    [self didChangeValueForKey:@"files"];
}

@end
