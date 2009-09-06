//
//  MetaLoader.h
//  MetaZ
//
//  Created by Brian Olsen on 25/08/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MZDataProvider.h"


@interface MZMetaLoader : NSObject {
    IBOutlet id<MZDataProvider> provider;
    NSMutableArray* files;
}
@property(readonly) NSArray* files;

+(MZMetaLoader *)sharedLoader;

-(NSArray *)types;
-(NSArray *)extensions;
-(void)loadFromFile:(NSString *)fileName;
-(void)loadFromFiles:(NSArray *)fileNames;

@end
