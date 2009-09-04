//
//  MetaLoadProvider.h
//  MetaZ
//
//  Created by Brian Olsen on 26/08/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//
#import "MetaLoaded.h"
#import "MetaEdits.h"

@protocol MZDataProvider <NSObject>

@required
-(NSArray *)types;
-(NSArray *)extensions;
-(NSArray *)providedKeys;
-(MetaLoaded *)loadFromFile:(NSString *)fileName;
-(void)saveChanges:(MetaEdits *)data toFile:(NSString *)fileName;

@end
