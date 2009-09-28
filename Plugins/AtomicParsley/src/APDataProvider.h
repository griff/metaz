//
//  AtomicParsleyMetaProvider.h
//  MetaZ
//
//  Created by Brian Olsen on 23/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/MetaZKit.h>

@interface APDataProvider : NSObject <MZDataProvider> {
    NSArray* types;
    NSArray* keys;
    NSDictionary* mapping;
}

- (id)init;

@end
