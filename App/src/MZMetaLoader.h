//
//  MetaLoader.h
//  MetaZ
//
//  Created by Brian Olsen on 25/08/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/MetaZKit.h>

@interface MZMetaLoader : NSObject
{
    NSMutableArray* files;
    NSOperationQueue* queue;
    MZVideoType defaultVideoType;
    MZVideoType lastSelection;
    NSUInteger loadingCount;
    NSMutableArray* loading;
}
@property(readonly) NSArray* files;

+ (MZMetaLoader *)sharedLoader;

- (NSArray *)types;
- (void)removeAllObjects;
- (BOOL)loadFromFile:(NSString *)fileName;
- (BOOL)loadFromFiles:(NSArray *)fileNames;
- (BOOL)loadFromFile:(NSString *)fileName toIndex:(NSUInteger)index;
- (BOOL)loadFromFiles:(NSArray *)fileNames toIndex:(NSUInteger)index;
- (BOOL)loadFromFiles:(NSArray *)fileNames toIndexes:(NSIndexSet*)indexes;
- (void)moveObjects:(NSArray *)objects toIndex:(NSUInteger)index;
- (void)reloadEdits:(MetaEdits *)edits;

@end
