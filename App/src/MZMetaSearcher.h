//
//  MZMetaSearch.h
//  MetaZ
//
//  Created by Brian Olsen on 04/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MZSearchProvider.h"

@interface MZMetaSearcher : NSObject {
    IBOutlet id<MZSearchProvider> provider;
    NSMutableArray* results;
}

@end
