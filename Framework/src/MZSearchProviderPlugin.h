//
//  MZSearchProviderPlugin.h
//  MetaZ
//
//  Created by Brian Olsen on 11/05/10.
//  Copyright 2010 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/MZPlugin.h>
#import <MetaZKit/MZSearchResult.h>

@class MZSearchProviderPlugin;

@protocol MZSearchProviderDelegate <NSObject>
- (void) searchProvider:(MZSearchProviderPlugin *)provider result:(NSArray*)result;
@optional
- (void) searchFinished;
@end

@interface MZSearchProviderPlugin : MZPlugin
{
    NSImage* icon;
@private
    id search;
    NSMutableArray* canceledSearches;
}

- (NSImage *)icon;
- (NSArray *)supportedSearchTags;
- (BOOL)searchWithData:(NSDictionary *)data
              delegate:(id<MZSearchProviderDelegate>)delegate
                 queue:(NSOperationQueue *)queue;
- (NSMenu *)menuForResult:(MZSearchResult *)result;

- (void)cancelSearch;
- (void)startSearch:(id)search;

@end
