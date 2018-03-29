//
//  MZDataProviderPlugin.m
//  MetaZ
//
//  Created by Brian Olsen on 17/11/12.
//  Copyright 2012 Maven-Group. All rights reserved.
//
#import "MZDataProviderPlugin.h"

@implementation MZDataProviderPlugin

- (BOOL)isEnabled
{
    return YES;
}

- (NSArray *)types
{
    NSArray* types = [self.bundle objectForInfoDictionaryKey:@"CFBundleDocumentTypes"];
    if(!types)
        [self doesNotRecognizeSelector:_cmd];
    NSMutableArray* ret = [NSMutableArray array];
    for(NSDictionary* dict in types)
    {
        NSArray* utis = [dict objectForKey:@"LSItemContentTypes"];
        [ret addObjectsFromArray:utis];
    }
    return ret;
}

- (NSArray *)providedTags;
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id<MZDataController>)loadFromFile:(NSString *)fileName
                            delegate:(id<MZDataReadDelegate>)deledate
                               queue:(NSOperationQueue *)queue
                               extra:(NSDictionary *)extra;
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id<MZDataController>)saveChanges:(MetaEdits *)data
                           delegate:(id<MZDataWriteDelegate>)delegate
                              queue:(NSOperationQueue *)queue;
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
