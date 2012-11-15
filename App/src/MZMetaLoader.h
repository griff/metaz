//
//  MetaLoader.h
//  MetaZ
//
//  Created by Brian Olsen on 25/08/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/MetaZKit.h>


@interface MZLoadOperation : NSObject <MZEditsReadDelegate>
{
    NSString* filePath;
    NSUInteger index;
    MetaEdits* edits;
    NSError* error;
    id<MZDataController> controller;
    id<MZEditsReadDelegate> delegate;
    NSScriptCommand* scriptCommand;
}

+ (id)loadWithFilePath:(NSString *)filePath atIndex:(NSUInteger )index extra:(NSDictionary *)extra;
- (id)initWithFilePath:(NSString *)filePath atIndex:(NSUInteger )index extra:(NSDictionary *)extra;

@property (readonly) NSString* filePath;
@property (readonly) NSUInteger index;
@property (readonly) MetaEdits* edits;
@property (readonly) NSError* error;
@property (retain) NSScriptCommand* scriptCommand;

@end

@interface MZMetaLoader : NSObject
{
    NSMutableArray* files;
    MZVideoType defaultVideoType;
    MZVideoType lastSelection;
    NSUInteger loadingCount;
    NSMutableArray* loading;
}
@property(readonly) NSArray* files;

+ (MZMetaLoader *)sharedLoader;

- (NSArray *)types;
- (void)removeAllObjects;
- (void)removeFilesAtIndexes:(NSIndexSet *)indexes;
- (void)removeObjectFromFilesAtIndex:(NSUInteger)idx;
- (BOOL)loadFromFile:(NSString *)fileName;
- (BOOL)loadFromFiles:(NSArray *)fileNames;
- (BOOL)loadFromFile:(NSString *)fileName toIndex:(NSUInteger)index;
- (BOOL)loadFromFiles:(NSArray *)fileNames toIndex:(NSUInteger)index;
- (BOOL)loadFromFiles:(NSArray *)fileNames toIndexes:(NSIndexSet*)indexes;
- (BOOL)loadFromFile:(NSString *)fileName withMetaData:(NSDictionary *)metaData;
- (BOOL)loadFromFiles:(NSArray *)fileNames withMetaData:(NSArray *)metaData;
- (BOOL)loadFromFile:(NSString *)fileName toIndex:(NSUInteger)index withMetaData:(NSDictionary *)metaData;
- (BOOL)loadFromFiles:(NSArray *)fileNames toIndex:(NSUInteger)index withMetaData:(NSArray *)metaData;
- (BOOL)loadFromFiles:(NSArray *)fileNames toIndexes:(NSIndexSet*)indexes withMetaData:(NSArray *)metaData;
- (void)moveObjects:(NSArray *)objects toIndex:(NSUInteger)index;
- (void)reloadEdits:(MetaEdits *)edits;

@end
