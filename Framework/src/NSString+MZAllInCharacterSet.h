//
//  NSString+MZAllInCharacterSet.h
//  MetaZ
//
//  Created by Brian Olsen on 08/08/11.
//  Copyright 2011 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSString (MZAllInCharacterSet)

- (BOOL)mz_allInCharacterSet:(NSCharacterSet *)set;

@end
