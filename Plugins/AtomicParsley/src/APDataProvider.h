//
//  AtomicParsleyMetaProvider.h
//  MetaZ
//
//  Created by Brian Olsen on 23/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/MetaZKit.h>

@interface APDataProvider : NSObject <MZDataProvider>
{
    NSArray* types;
    NSArray* tags;
    NSDictionary* read_mapping;
    NSDictionary* write_mapping;
    NSDictionary* rating_read;
    NSDictionary* rating_write;
    NSMutableArray* writes;
}

+ (void)logFromProgram:(NSString *)program pipe:(NSPipe *)pipe;
+ (int)testReadFile:(NSString *)filePath;
+ (int)removeChaptersFromFile:(NSString *)filePath;
+ (int)importChaptersFromFile:(NSString *)chaptersFile toFile:(NSString *)filePath;

- (id)init;
- (void)removeWriteManager:(id)writeManager;

- (void)parseData:(NSData *)data withFileName:(NSString *)fileName dict:(NSMutableDictionary *)tagdict;

@end
