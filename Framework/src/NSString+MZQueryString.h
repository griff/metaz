//
//  NSString+MZQueryString.h
//  MetaZ
//
//  Created by Brian Olsen on 16/12/11.
//  Copyright 2011 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSString (MZQueryString)

+ (NSString *)mz_queryStringForParameterDictionary:(NSDictionary *)theParameters;

@end
