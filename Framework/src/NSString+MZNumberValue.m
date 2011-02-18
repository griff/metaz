//
//  NSString+MZNumberValue.m
//  MetaZ
//
//  Created by Brian Olsen on 09/01/11.
//  Copyright 2011 Maven-Group. All rights reserved.
//

#import "NSString+MZNumberValue.h"


@implementation NSString (MZNumberValue)

- (NSNumber *)mz_numberIntegerValue {
    return [NSNumber numberWithInteger:[self integerValue]];
}

- (NSNumber *)mz_numberIntValue {
    return [NSNumber numberWithInt:[self intValue]];
}

- (NSNumber *)mz_numberFloatValue {
    return [NSNumber numberWithFloat:[self floatValue]];
}

- (NSNumber *)mz_numberDoubleValue {
    return [NSNumber numberWithDouble:[self doubleValue]];
}

- (NSNumber *)mz_numberLongLongValue {
    return [NSNumber numberWithLongLong:[self longLongValue]];
}

- (NSNumber *)mz_numberBoolValue {
    return [NSNumber numberWithBool:[self boolValue]];
}


@end
