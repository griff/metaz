//
//  NSString+MZRemoveString.h
//  MetaZ
//
//  Created by Brian Olsen on 14/01/11.
//  Copyright 2011 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSString (MZRemoveString)

- (NSString *)mz_stringByRemovingSubstringInRange:(NSRange)range;

@end
