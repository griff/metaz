//
//  NSString+MimeTypePattern.h
//  MetaZ
//
//  Created by Brian Olsen on 08/12/12.
//  Copyright 2012 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSString (MimeTypePattern)

- (BOOL)matchesMimeTypePattern:(NSString *)pattern;

@end
