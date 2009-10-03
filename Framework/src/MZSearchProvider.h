//
//  MZSearchProvider.h
//  MetaZ
//
//  Created by Brian Olsen on 04/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <MetaZKit/MetaData.h>

@protocol MZSearchProvider <NSObject>
- (NSImage *)icon;
- (NSString *)identifier;
- (NSArray *)searchWithData:(id<MetaData>)data;
- (NSArray *)searchWithString:(NSString *)data;
@end
