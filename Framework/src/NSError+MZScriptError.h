//
//  NSError+MZScriptError.h
//  MetaZ
//
//  Created by Brian Olsen on 05/11/12.
//  Copyright 2012 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSError (MZScriptError)

+ (id)errorWithAppleScriptError:(NSDictionary *)errDict;
- (id)initWithAppleScriptError:(NSDictionary *)errDict;

@end
