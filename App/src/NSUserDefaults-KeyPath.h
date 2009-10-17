//
//  NSUserDefaults-KeyPath.h
//  MetaZ
//
//  Created by Brian Olsen on 17/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSUserDefaults (MZKeyPaths)

- (BOOL)boolForKeyPath:(NSString *)defaultName;

- (void)setBool:(BOOL)value forKeyPath:(NSString *)defaultName;
@end
