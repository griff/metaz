//
//  MZMetaSearch.h
//  MetaZ
//
//  Created by Brian Olsen on 04/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MZSearchProvider.h"

@interface MZMetaSearcher : NSObject <MZSearchProviderDelegate> {
    NSMutableArray* results;
    BOOL hasFake;
}
@property(readonly) NSArray* results;
@property(retain) id fakeResult;

+ (MZMetaSearcher *)sharedSearcher;

- (void)startSearchWithData:(NSDictionary *)data;
- (void)clearResults;

@end
