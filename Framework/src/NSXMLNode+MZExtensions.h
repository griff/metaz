//
//  NSXMLNode-Accessors.h
//  MetaZ
//
//  Created by Brian Olsen on 12/11/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSXMLNode (MZExtensions)

- (NSString *)stringForXPath:(NSString *)xpath error:(NSError **)error;

@end
