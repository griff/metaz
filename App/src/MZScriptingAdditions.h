//
//  MZScriptingAdditions.h
//  MetaZ
//
//  Created by Brian Olsen on 30/10/12.
//  Copyright 2012 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSValue (MZScriptingAdditions)
+ (id)valueWithFourCharCode:(FourCharCode)code;
- (FourCharCode)fourCharCode;
@end

@interface NSNumber (MZScriptingAdditions)
+ (id)scriptingNumberWithDescriptor:(NSAppleEventDescriptor *)desc;
- (NSAppleEventDescriptor *)scriptingAnyDescriptor;
@end

@interface NSDate (MZScriptingAdditions)
+ (id)scriptingDateWithDescriptor:(NSAppleEventDescriptor *)desc;
- (NSAppleEventDescriptor *)scriptingAnyDescriptor;
@end

@interface NSString (MZScriptingAdditions)
+ (id)scriptingStringWithDescriptor:(NSAppleEventDescriptor *)desc;
- (NSAppleEventDescriptor *)scriptingAnyDescriptor;
@end

@interface NSArray (MZScriptingAdditions)
+ (id)scriptingListWithDescriptor:(NSAppleEventDescriptor *)desc;
- (NSAppleEventDescriptor *)scriptingAnyDescriptor;
@end

@interface NSDictionary (MZScriptingAdditions)
+ (id)scriptingRecordWithDescriptor:(NSAppleEventDescriptor *)desc;
@end

@interface NSNull (MZScriptingAdditions)
- (NSAppleEventDescriptor *)scriptingAnyDescriptor;
@end

@interface NSAppleEventDescriptor (MZScriptingAdditions)
+ (id)descriptorWithInt16:(SInt16)value;
- (SInt16)int16Value;

+ (id)descriptorWithInt64:(SInt64)value;
- (SInt64)int64Value;

+ (id)descriptorWithUnsignedInt16:(UInt16)value;
- (UInt16)unsignedInt16Value;

+ (id)descriptorWithUnsignedInt32:(UInt32)value;
- (UInt32)unsignedInt32Value;

+ (id)descriptorWithUnsignedInt64:(UInt64)value;
- (UInt64)unsignedInt64Value;

+ (id)descriptorWithFloat32:(Float32)value;
- (Float32)float32Value;

+ (id)descriptorWithFloat64:(Float64)value;
- (Float64)float64Value;

+ (id)descriptorWithDecimal:(NSDecimal)value;
- (NSDecimal)decimalValue;

+ (id)descriptorWithLongDateTime:(LongDateTime)time;
- (LongDateTime)longDateTimeValue;

- (id)objectValue;
@end