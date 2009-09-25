//
//  AtomicParsleyMetaProvider.h
//  MetaZ
//
//  Created by Brian Olsen on 23/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MZDataProvider.h"

@interface AtomicParsleyDataProvider : NSObject <MZDataProvider> {
    NSArray* types;
    NSArray* extensions;
    NSArray* keys;
    NSDictionary* mapping;
}

- (id)init;

@end
