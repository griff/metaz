//
//  NSObject+WaitUntilChange.h
//  MetaZ
//
//  Created by Brian Olsen on 06/05/10.
//  Copyright 2010 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSObject (WaitUntilChange)

- (void)waitForChangedKeyPath:(NSString *)keyPath;

@end
