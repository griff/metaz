//
//  NSString+TempFile.h
//  MetaZ
//
//  Created by Brian Olsen on 19/01/10.
//  Copyright 2010 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSString (MZTempFile)

+ (id)temporaryPathWithFormat:(NSString *)format;

@end
