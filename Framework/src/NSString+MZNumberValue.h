//
//  NSString+MZNumberValue.h
//  MetaZ
//
//  Created by Brian Olsen on 09/01/11.
//  Copyright 2011 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSString (MZNumberValue)

- (NSNumber *)mz_numberIntegerValue;
- (NSNumber *)mz_numberIntValue;
- (NSNumber *)mz_numberFloatValue;
- (NSNumber *)mz_numberDoubleValue;
- (NSNumber *)mz_numberLongLongValue;
- (NSNumber *)mz_numberBoolValue;

@end
