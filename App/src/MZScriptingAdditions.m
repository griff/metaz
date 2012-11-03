//
//  MZScriptingAdditions.m
//  MetaZ
//
//  Created by Brian Olsen on 30/10/12.
//  Copyright 2012 Maven-Group. All rights reserved.
//

#import "MZScriptingAdditions.h"
#import "MZScriptingEnums.h"

const AEKeyword keyASUserRecordFields         = 'usrf';

@implementation NSValue (MZScriptingAdditions)

+ (id)valueWithFourCharCode:(FourCharCode)code;
{
    return [NSValue valueWithBytes:&code objCType:@encode(FourCharCode)];
}

- (FourCharCode)fourCharCode;
{
   FourCharCode ret;
   [self getValue:&ret];
   return ret; 
}

@end


@implementation NSNumber (MZScriptingAdditions)

+ (id)scriptingSignedIntWithBytes:(void *)bytes ofSize:(int)size
{
    if(size == sizeof(char))
        return [self numberWithChar:*(char *)bytes];
    if(size == sizeof(short))
        return [self numberWithShort:*(short *)bytes];
    if(size == sizeof(int))
        return [self numberWithInt:*(int *)bytes];
    if(size == sizeof(long))
        return [self numberWithLong:*(long *)bytes];
    if(size == sizeof(long long))
        return [self numberWithLongLong:*(long long *)bytes];

    [NSException raise:NSInvalidArgumentException
                format:@"Signed number with %d bytes not supported", size];
    return nil;
}

+ (id)scriptingUnsignedIntWithBytes:(void *)bytes ofSize:(int)size
{
    if(size == sizeof(unsigned char))
        return [self numberWithUnsignedChar:*(unsigned char *)bytes];
    if(size == sizeof(unsigned short))
        return [self numberWithUnsignedShort:*(unsigned short *)bytes];
    if(size == sizeof(unsigned int))
        return [self numberWithUnsignedInt:*(unsigned int *)bytes];
    if(size == sizeof(unsigned long))
        return [self numberWithUnsignedLong:*(unsigned long *)bytes];
    if(size == sizeof(unsigned long long))
        return [self numberWithUnsignedLongLong:*(unsigned long long *)bytes];

    [NSException raise:NSInvalidArgumentException
                format:@"Unsigned number with %d bytes not supported", size];
    return nil;
}

+ (id)scriptingFloatWithBytes:(void *)bytes ofSize:(int)size
{
    if(size == sizeof(float))
        return [self numberWithFloat:*(float *)bytes];
    if(size == sizeof(double))
        return [self numberWithDouble:*(double *)bytes];

    [NSException raise:NSInvalidArgumentException
                format:@"Float number with %d bytes not supported", size];
    return nil;
}

+ (id)scriptingNumberWithDescriptor:(NSAppleEventDescriptor *)desc;
{
    DescType type = [desc descriptorType];
    
    if(type == typeTrue || type == typeFalse || type == typeBoolean)
        return [self numberWithBool:[desc booleanValue]];
        
    if(type == typeSInt16)
    {
        SInt16 val = [desc int16Value];
        return [self scriptingSignedIntWithBytes:&val ofSize:sizeof(val)];
    }
    
    if(type == typeSInt32)
    {
        SInt32 val = [desc int32Value];
        return [self scriptingSignedIntWithBytes:&val ofSize:sizeof(val)];
    }
    
    if(type == typeSInt64)
    {
        SInt64 val = [desc int32Value];
        return [self scriptingSignedIntWithBytes:&val ofSize:sizeof(val)];
    }
        
    if(type == typeUInt16)
    {
        UInt16 val = [desc unsignedInt16Value];
        return [self scriptingUnsignedIntWithBytes:&val ofSize:sizeof(val)];
    }
    
    if(type == typeUInt32)
    {
        UInt32 val = [desc unsignedInt32Value];
        return [self scriptingUnsignedIntWithBytes:&val ofSize:sizeof(val)];
    }
    
    if(type == typeUInt64)
    {
        UInt64 val = [desc unsignedInt32Value];
        return [self scriptingUnsignedIntWithBytes:&val ofSize:sizeof(val)];
    }
    
    if(type == typeIEEE32BitFloatingPoint)
    {
        Float32 val = [desc float32Value];
        return [self scriptingFloatWithBytes:&val ofSize:sizeof(val)];
    }
    
    if(type == typeIEEE64BitFloatingPoint)
    {
        Float64 val = [desc float64Value];
        return [self scriptingFloatWithBytes:&val ofSize:sizeof(val)];
    }
    
    desc = [desc coerceToDescriptorType:typeIEEE64BitFloatingPoint];
    if(desc)
    {
        Float64 val = [desc float64Value];
        return [self scriptingFloatWithBytes:&val ofSize:sizeof(val)];
    }
    
    [NSException raise:NSInvalidArgumentException
        format:@"Could not convert NSAppleEventDescriptor of type %s to NSNumber", type];
    return nil;
}

- (NSAppleEventDescriptor *)scriptingFloatDescriptorWithBytes:(void *)bytes ofSize:(int)size;
{
    Float32 val;
    if(size < sizeof(Float32))
    {
        val = [self floatValue];
        bytes = &val;
        size = sizeof(val);
    }
    
    if(size == sizeof(Float32))
        return [NSAppleEventDescriptor descriptorWithFloat32:*(Float32*)bytes];
    if(size == sizeof(Float64))
        return [NSAppleEventDescriptor descriptorWithFloat64:*(Float64*)bytes];
    
    [NSException raise:NSInvalidArgumentException
                format:@"Cannot make NSAppleEventDescriptor for float with %d bytes of data", size];
    return nil;
}

- (NSAppleEventDescriptor *)scriptingSignedIntDescriptorWithBytes:(void *)bytes ofSize:(int)size;
{
    SInt16 val;
    if(size < sizeof(SInt16))
    {
        val = [self intValue];
        bytes = &val;
        size = sizeof(val);
    }
    
    if(size == sizeof(SInt16))
        return [NSAppleEventDescriptor descriptorWithInt16:*(SInt16*)bytes];
    if(size == sizeof(SInt32))
        return [NSAppleEventDescriptor descriptorWithInt32:*(SInt32*)bytes];
    if(size == sizeof(SInt64))
        return [NSAppleEventDescriptor descriptorWithInt64:*(SInt64*)bytes];
        
    Float64 dbl = [self doubleValue];
    return [self scriptingFloatDescriptorWithBytes:&dbl ofSize:sizeof(dbl)];
}

- (NSAppleEventDescriptor *)scriptingUnsignedIntDescriptorWithBytes:(void *)bytes ofSize:(int)size;
{
    UInt16 val;
    if(size < sizeof(UInt16))
    {
        val = [self unsignedIntValue];
        bytes = &val;
        size = sizeof(val);
    }
    
    if(size == sizeof(UInt16))
        return [NSAppleEventDescriptor descriptorWithUnsignedInt16:*(UInt16*)bytes];
    if(size == sizeof(UInt32))
        return [NSAppleEventDescriptor descriptorWithUnsignedInt32:*(UInt32*)bytes];
    if(size == sizeof(UInt64))
        return [NSAppleEventDescriptor descriptorWithUnsignedInt64:*(UInt64*)bytes];
        
    Float64 dbl = [self doubleValue];
    return [self scriptingFloatDescriptorWithBytes:&dbl ofSize:sizeof(dbl)];
}

- (NSAppleEventDescriptor *)scriptingAnyDescriptor;
{
    const char *type = [self objCType];
    
    if(strcmp(type, @encode(BOOL))==0)
        return [NSAppleEventDescriptor descriptorWithBoolean:[self boolValue]];
    if(strcmp(type, @encode(char))==0)
    {
        char val = [self charValue];
        return [self scriptingSignedIntDescriptorWithBytes:&val ofSize:sizeof(val)];
    }
    if(strcmp(type, @encode(double))==0)
    {
        double val = [self doubleValue];
        return [self scriptingFloatDescriptorWithBytes:&val ofSize:sizeof(val)];
    }
    if(strcmp(type, @encode(float))==0)
    {
        float val = [self floatValue];
        return [self scriptingFloatDescriptorWithBytes:&val ofSize:sizeof(val)];
    }
    if(strcmp(type, @encode(int))==0)
    {
        int val = [self intValue];
        return [self scriptingSignedIntDescriptorWithBytes:&val ofSize:sizeof(val)];
    }
    if(strcmp(type, @encode(NSInteger))==0)
    {
        NSInteger val = [self integerValue];
        return [self scriptingSignedIntDescriptorWithBytes:&val ofSize:sizeof(val)];
    }
    if(strcmp(type, @encode(long long))==0)
    {
        long long val = [self longLongValue];
        return [self scriptingSignedIntDescriptorWithBytes:&val ofSize:sizeof(val)];
    }
    if(strcmp(type, @encode(long))==0)
    {
        long val = [self longValue];
        return [self scriptingSignedIntDescriptorWithBytes:&val ofSize:sizeof(val)];
    }
    if(strcmp(type, @encode(short))==0)
    {
        short val = [self shortValue];
        return [self scriptingSignedIntDescriptorWithBytes:&val ofSize:sizeof(val)];
    }
    if(strcmp(type, @encode(unsigned char))==0)
    {
        unsigned char val = [self unsignedCharValue];
        return [self scriptingUnsignedIntDescriptorWithBytes:&val ofSize:sizeof(val)];
    }
    if(strcmp(type, @encode(NSUInteger))==0)
    {
        NSUInteger val = [self unsignedIntegerValue];
        return [self scriptingUnsignedIntDescriptorWithBytes:&val ofSize:sizeof(val)];
    }
    if(strcmp(type, @encode(unsigned int))==0)
    {
        unsigned int val = [self unsignedIntValue];
        return [self scriptingUnsignedIntDescriptorWithBytes:&val ofSize:sizeof(val)];
    }
    if(strcmp(type, @encode(unsigned long long))==0)
    {
        unsigned long long val = [self unsignedLongLongValue];
        return [self scriptingUnsignedIntDescriptorWithBytes:&val ofSize:sizeof(val)];
    }
    if(strcmp(type, @encode(unsigned long))==0)
    {
        unsigned long val = [self unsignedLongValue];
        return [self scriptingUnsignedIntDescriptorWithBytes:&val ofSize:sizeof(val)];
    }
    if(strcmp(type, @encode(unsigned short))==0)
    {
        unsigned short val = [self unsignedShortValue];
        return [self scriptingUnsignedIntDescriptorWithBytes:&val ofSize:sizeof(val)];
    }

    [NSException raise:@"MZScriptingAdditionsConversionException"
                format:@"Cannot make NSAppleEventDescriptor for NSNumber with objCType %s", type];
    return nil;
}

@end


@implementation NSDate (MZScriptingAdditions)

+ (id)scriptingDateWithDescriptor:(NSAppleEventDescriptor *)desc;
{
    CFAbsoluteTime absTime;
    UCConvertLongDateTimeToCFAbsoluteTime([desc longDateTimeValue], &absTime);
    NSDate *resultDate = (NSDate *)CFDateCreate(NULL, absTime);
    return resultDate;
}

- (NSAppleEventDescriptor *)scriptingAnyDescriptor;
{
    CFAbsoluteTime absTime;
    absTime = CFDateGetAbsoluteTime((CFDateRef)self);
    LongDateTime longDateTime;
    UCConvertCFAbsoluteTimeToLongDateTime(absTime, &longDateTime);
    return [NSAppleEventDescriptor descriptorWithLongDateTime:longDateTime];
}

@end


@implementation NSString (MZScriptingAdditions)

+ (id)scriptingStringWithDescriptor:(NSAppleEventDescriptor *)desc;
{
    return [desc stringValue];
}

- (NSAppleEventDescriptor *)scriptingAnyDescriptor;
{
    return [NSAppleEventDescriptor descriptorWithString:self]; 
}

@end


@implementation NSArray (MZScriptingAdditions)

+ (id)scriptingListWithDescriptor:(NSAppleEventDescriptor *)desc;
{
    desc = [desc coerceToDescriptorType:typeAEList];
    NSInteger count = [desc numberOfItems];
    NSMutableArray* arr = [NSMutableArray arrayWithCapacity:count];
    
    for(NSUInteger i=1; i<=count; i++)
    {
        NSAppleEventDescriptor* item = [desc descriptorAtIndex:i];
        [arr addObject:[item objectValue]];
    }
    
    return [self arrayWithArray:arr];
}

- (NSAppleEventDescriptor *)scriptingAnyDescriptor;
{
    NSAppleEventDescriptor* ret = [NSAppleEventDescriptor listDescriptor];
    for(id obj in self)
    {
        id specifier = [obj objectSpecifier];
        if(specifier)
            obj = specifier;
        [ret insertDescriptor:[obj scriptingAnyDescriptor] atIndex:0];
    }
    return ret;
}

@end


@implementation NSDictionary (MZScriptingAdditions)

+ (id)scriptingRecordWithDescriptor:(NSAppleEventDescriptor *)desc;
{
    desc = [desc coerceToDescriptorType:typeAERecord];
    NSInteger count = [desc numberOfItems];
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:count];
    
    for(NSUInteger i=1; i<=count; i++)
    {
        AEKeyword keyword = [desc keywordForDescriptorAtIndex:i];
        if(keyword == keyASUserRecordFields)
        {
            NSAppleEventDescriptor* list = [desc descriptorForKeyword:keyword];
            NSInteger listCount = [list numberOfItems];
            for(NSInteger idx=1; idx<=listCount; idx+=2)
            {
                id key = [[list descriptorAtIndex:idx] objectValue];
                id value = [[list descriptorAtIndex:idx+1] objectValue];
                [dict setObject:value forKey:key];
            }
        }
        else
        {
            NSValue* key = [NSValue valueWithFourCharCode:keyword];
            NSAppleEventDescriptor* item = [desc descriptorForKeyword:keyword];
            [dict setObject:[item objectValue] forKey:key];
        }

    }
    return [self dictionaryWithDictionary:dict];
}

@end


@implementation NSNull (MZScriptingAdditions)

- (NSAppleEventDescriptor *)scriptingAnyDescriptor;
{
    return [NSAppleEventDescriptor nullDescriptor];
}

@end


@implementation NSAppleEventDescriptor (MZScriptingAdditions)

+ (id)descriptorWithInt16:(SInt16)value;
{
    return [NSAppleEventDescriptor descriptorWithDescriptorType:typeSInt16 bytes:&value length:sizeof(value)];
}

- (SInt16)int16Value;
{
    NSAppleEventDescriptor* coerced = [self coerceToDescriptorType:typeSInt16];
    SInt16 val;
    [[coerced data] getBytes:&val length:sizeof(val)];
    return val;
}

+ (id)descriptorWithInt64:(SInt64)value;
{
    return [NSAppleEventDescriptor descriptorWithDescriptorType:typeSInt64 bytes:&value length:sizeof(value)];
}

- (SInt64)int64Value;
{
    NSAppleEventDescriptor* coerced = [self coerceToDescriptorType:typeSInt64];
    SInt64 val;
    [[coerced data] getBytes:&val length:sizeof(val)];
    return val;
}

+ (id)descriptorWithUnsignedInt16:(UInt16)value;
{
    return [NSAppleEventDescriptor descriptorWithDescriptorType:typeUInt16 bytes:&value length:sizeof(value)];
}

- (UInt16)unsignedInt16Value;
{
    NSAppleEventDescriptor* coerced = [self coerceToDescriptorType:typeUInt16];
    UInt16 val;
    [[coerced data] getBytes:&val length:sizeof(val)];
    return val;
}

+ (id)descriptorWithUnsignedInt32:(UInt32)value;
{
    return [NSAppleEventDescriptor descriptorWithDescriptorType:typeUInt32 bytes:&value length:sizeof(value)];
}

- (UInt32)unsignedInt32Value;
{
    NSAppleEventDescriptor* coerced = [self coerceToDescriptorType:typeUInt32];
    UInt32 val;
    [[coerced data] getBytes:&val length:sizeof(val)];
    return val;
}

+ (id)descriptorWithUnsignedInt64:(UInt64)value;
{
    return [NSAppleEventDescriptor descriptorWithDescriptorType:typeUInt64 bytes:&value length:sizeof(value)];
}

- (UInt64)unsignedInt64Value;
{
    NSAppleEventDescriptor* coerced = [self coerceToDescriptorType:typeUInt64];
    UInt64 val;
    [[coerced data] getBytes:&val length:sizeof(val)];
    return val;
}

+ (id)descriptorWithFloat32:(Float32)value;
{
    return [NSAppleEventDescriptor descriptorWithDescriptorType:typeIEEE32BitFloatingPoint bytes:&value length:sizeof(value)];
}

- (Float32)float32Value;
{
    NSAppleEventDescriptor* coerced = [self coerceToDescriptorType:typeIEEE32BitFloatingPoint];
    Float32 val;
    [[coerced data] getBytes:&val length:sizeof(val)];
    return val;
}

+ (id)descriptorWithFloat64:(Float64)value;
{
    return [NSAppleEventDescriptor descriptorWithDescriptorType:typeIEEE64BitFloatingPoint bytes:&value length:sizeof(value)];
}

- (Float64)float64Value;
{
    NSAppleEventDescriptor* coerced = [self coerceToDescriptorType:typeIEEE64BitFloatingPoint];
    Float64 val;
    [[coerced data] getBytes:&val length:sizeof(val)];
    return val;
}

+ (id)descriptorWithDecimal:(NSDecimal)value;
{
    return [NSAppleEventDescriptor descriptorWithDescriptorType:typeDecimalStruct bytes:&value length:sizeof(value)];
}

- (NSDecimal)decimalValue;
{
    NSAppleEventDescriptor* coerced = [self coerceToDescriptorType:typeDecimalStruct];
    NSDecimal val;
    [[coerced data] getBytes:&val length:sizeof(val)];
    return val;
}

+ (id)descriptorWithLongDateTime:(LongDateTime)time;
{
    return [NSAppleEventDescriptor descriptorWithDescriptorType:typeLongDateTime bytes:&time length:sizeof(time)];
}

- (LongDateTime)longDateTimeValue;
{
    NSAppleEventDescriptor* coerced = [self coerceToDescriptorType:typeLongDateTime];
    LongDateTime longDateTime;
    [[coerced data] getBytes:&longDateTime length:sizeof(longDateTime)];
    return longDateTime;
}

- (id)objectValue;
{
    DescType descType = [self descriptorType];

    switch(descType) {
        case typeUnicodeText:
        case typeCString:
        case typeUTF8Text:
        case typeUTF16ExternalRepresentation:
            return [NSString scriptingStringWithDescriptor:self];
        case typeSInt16:
        case typeSInt32:
        case typeSInt64:
        case typeUInt16:
        case typeUInt32:
        case typeUInt64:
        case typeIEEE32BitFloatingPoint:
        case typeIEEE64BitFloatingPoint:
        case typeTrue:
        case typeFalse:
        case typeBoolean:
            return [NSNumber scriptingNumberWithDescriptor:self];
        case typeDecimalStruct:
            {
                NSDecimal val;
                [[self data] getBytes:&val];
                return [NSValue valueWithBytes:&val objCType:@encode(NSDecimal)];
            }
        case typeEnumerated:
            {
                OSType ret = [self enumCodeValue];
                MZScriptingEnumerator* e = [[MZScriptingEnums scriptingEnumsForMainBundle] enumValueWithCode:ret];
                return [e objectValue];
            }
        case typeLongDateTime:
            return [NSDate scriptingDateWithDescriptor:self];
        case typeNull:
            return [NSNull null];
        case typeType:
            {
                OSType ret = [self typeCodeValue];
                if(ret == typeNull)
                    return [NSNull null];
                break;
            }
        case typeAEList:
            return [NSArray scriptingListWithDescriptor:self];
        case typeAERecord:
            return [NSDictionary scriptingRecordWithDescriptor:self];
            
        case typeObjectSpecifier:
            return [NSScriptObjectSpecifier objectSpecifierWithDescriptor:self];
            
    }
    return self;
}

@end