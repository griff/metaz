//
//  MetaLoader.h
//  MetaZ
//
//  Created by Brian Olsen on 25/08/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/MetaZKit.h>

@interface MZMetaLoader : NSObject {
    NSMutableArray* files;
}
@property(readonly) NSArray* files;

+ (MZMetaLoader *)sharedLoader;

- (NSArray *)types;
- (void)removeAllObjects;
- (void)loadFromFile:(NSString *)fileName;
- (void)loadFromFiles:(NSArray *)fileNames;
- (void)loadFromFile:(NSString *)fileName toIndex:(NSUInteger)index;
- (void)loadFromFiles:(NSArray *)fileNames toIndex:(NSUInteger)index;
- (void)loadFromFiles:(NSArray *)fileNames toIndexes:(NSIndexSet*)indexes;
- (void)moveObjects:(NSArray *)objects toIndex:(NSUInteger)index;

@end
