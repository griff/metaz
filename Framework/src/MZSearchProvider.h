//
//  MZSearchProvider.h
//  MetaZ
//
//  Created by Brian Olsen on 04/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MetaData.h"

@protocol MZSearchProvider <NSObject>
-(NSArray *)search:(id<MetaData>)data;
-(NSArray *)search:(NSString *)data;

@end
