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
        [[MZMetaLoader alloc] init];
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
    return [provider types];
}

-(NSArray *)extensions {
    NSArray* ret = [provider extensions];
    return ret;
}

-(void)loadFromFile:(NSString *)fileName {
    [self willChangeValueForKey:@"files"];
    MetaLoaded* loaded = [provider loadFromFile:fileName];
    MetaEdits* edits = [[MetaEdits alloc] initWithProvider:loaded];
    [files addObject:edits];
    [self didChangeValueForKey:@"files"];
}

-(void)loadFromFiles:(NSArray *)fileNames {
    [self willChangeValueForKey:@"files"];
    for ( NSString* fileName in fileNames )
    {
        MetaLoaded* loaded = [provider loadFromFile:fileName];
        MetaEdits* edits = [[MetaEdits alloc] initWithProvider:loaded];
        NSString* title = [edits title];
        if(title == nil)
        {
            NSString* loadedFileName = [edits fileName];
            NSAssert(loadedFileName != nil, @"Bad loaded file name");
            NSAssert( ((NSNull*)loadedFileName) != [NSNull null], @"Bad loaded file name" );
            NSString* newTitle = [loadedFileName substringToIndex:[loadedFileName length] - [[loadedFileName pathExtension] length] - 1];
            [edits setTitle:newTitle];
        }
        [files addObject:edits];
    }
    [self didChangeValueForKey:@"files"];
}

@end
