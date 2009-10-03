//
//  NSInvocation-Wrapping.h
//  MetaZ
//
//  Created by Brian Olsen on 03/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSInvocation (Wrapping)

- (void)setReturnObject:(id)value;
- (id)returnObject;
- (void)setArgumentObject:(id)argument atIndex:(NSInteger)idx;
- (id)argumentObjectAtIndex:(NSInteger)idx;

@end
