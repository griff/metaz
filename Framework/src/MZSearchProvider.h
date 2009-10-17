//
//  MZSearchProvider.h
//  MetaZ
//
//  Created by Brian Olsen on 04/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <MetaZKit/MetaData.h>
#import <MetaZKit/MZSearchResult.h>

@protocol MZSearchProvider;

@protocol MZSearchProviderDelegate <NSObject>
- (void) searchProvider:(id<MZSearchProvider>)provider result:(NSArray*)result;
@optional
- (void) searchFinished;
@end


@protocol MZSearchProvider <NSObject>
- (NSImage *)icon;
- (NSString *)identifier;
- (NSArray *)supportedSearchTags;
- (BOOL)searchWithData:(NSDictionary *)data delegate:(id<MZSearchProviderDelegate>)delegate;
@optional
- (NSMenu *)menuForResult:(MZSearchResult *)result;
@end
