//
//  MZBaseSearchProvider.h
//  MetaZ
//
//  Created by Brian Olsen on 11/05/10.
//  Copyright 2010 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MZBaseSearchProvider : NSObject
{
@private
    id search;
    NSMutableArray* canceledSearches;
}

- (void)cancelSearch;
- (void)startSearch:(id)search;

@end
