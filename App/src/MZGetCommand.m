//
//  MZGetCommand.m
//  MetaZ
//
//  Created by Brian Olsen on 30/10/12.
//  Copyright 2012 Maven-Group. All rights reserved.
//

#import "MZGetCommand.h"


@implementation MZGetCommand

- (id)performDefaultImplementation
{
    id ret = [super performDefaultImplementation];
    NSAppleEventDescriptor* rtypDesc = [[self appleEvent] paramDescriptorForKeyword:'rtyp'];
    if( rtypDesc ) { // the get command is requesting a coercion (requested type)
        OSType tp = [rtypDesc typeCodeValue];
        if([ret isKindOfClass:[NSAppleEventDescriptor class]])
        {
            DescType type = [ret descriptorType];
            if(tp == type)
                return ret;
                
            NSAppleEventDescriptor* coerced = [ret coerceToDescriptorType:tp];
            if(coerced)
                return coerced;
                
            // The above doesn't work for number so do that manually
            if(tp == 'nmbr')
            {
                switch (type) {
                    case typeSInt16:
                    case typeSInt32:
                    case typeSInt64:
                    case typeUInt16:
                    case typeUInt32:
                    case typeUInt64:
                    case typeIEEE32BitFloatingPoint:
                    case typeIEEE64BitFloatingPoint:
                    case type128BitFloatingPoint:
                    case typeDecimalStruct:
                        return ret;
                }
            }
        }
        id value = [self evaluatedReceivers];
        if(!value)
            return ret;
        NSScriptClassDescription* classDesc = [[NSScriptSuiteRegistry sharedScriptSuiteRegistry] classDescriptionWithAppleEventCode:tp];
        Class class = NULL;
        
        if( classDesc ) { // found the requested type in the script suites.
            class = NSClassFromString( [classDesc className] );
        } else { // catch some common types that don't have entries in the script suites.
            switch( tp ) {
                case typeText:
                case typeUnicodeText:
                    class = [NSString class]; break;
                case typeStyledText: class = [NSTextStorage class]; break;
                case typeSInt32:
                case 'nmbr': class = [NSNumber class]; break;
                case typeAERecord: class = [NSDictionary class]; break;
                case typeAEList: class = [NSArray class]; break;
                case 'data': class = [NSData class]; break;
            }
        }
        
        if( class && class != [value class] ) {
            id newRet = [[NSScriptCoercionHandler sharedCoercionHandler] coerceValue:value toClass:class];
            if( newRet ) return newRet;
        }
        
        // account for basic types that wont have a coercion handler but have common methods we can use.
        if( class == [NSString class] && [ret respondsToSelector:@selector( stringValue )] )
            return [ret stringValue];
        else if( class == [NSString class] )
            return [ret description];
        else if( [rtypDesc typeCodeValue] == typeSInt32 && [ret respondsToSelector:@selector( intValue )] )
            return [NSNumber numberWithLong:[ret intValue]];
        else if( [rtypDesc typeCodeValue] == typeIEEE32BitFloatingPoint && [ret respondsToSelector:@selector( floatValue )] )
            return [NSNumber numberWithFloat:[ret floatValue]];
        else if( ( [rtypDesc typeCodeValue] == typeIEEE64BitFloatingPoint ||
                   [rtypDesc typeCodeValue] == 'nmbr' ) && 
                 [ret respondsToSelector:@selector( doubleValue )] )
        {
            return [NSNumber numberWithDouble:[ret doubleValue]];
        }
        if([value respondsToSelector:@selector(objectSpecifier)])
            value = [value objectSpecifier];
        if(value)
            ret = value;
    }
    return ret;
}

@end
