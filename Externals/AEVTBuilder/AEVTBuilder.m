//
//  AEVTBuilder.m
//
// Created by Michael Ash (http://www.mikeash.com/)
// 
// Copyright (c) 2005 Ultralingua
// 
// This software is provided 'as-is', without any express or implied
// warranty. In no event will the authors be held liable for any
// damages arising from the use of this software.
// 
// Permission is granted to anyone to use this software for any
// purpose, including commercial applications, and to alter it and
// redistribute it freely, subject to the following restrictions:
// 
// 1. The origin of this software must not be misrepresented; you
// must not claim that you wrote the original software. If you use
// this software in a product, an acknowledgment in the product
// documentation would be appreciated but is not required.
// 
// 2. Altered source versions must be plainly marked as such, and
// must not be misrepresented as being the original software.
// 
// 3. This notice may not be removed or altered from any source
// distribution.
//
// Please see http://www.cocoadev.com/index.pl?AEVTBuilder for
// information on this code.
// 

#import "AEVTBuilder.h"

#import <stdarg.h>


id AEVT             = nil;

id RECORD           = nil;
OSType ENDRECORD    = 0;

id KEY              = nil;
id TYPE             = nil;
id INT              = nil;
id ENUM             = nil;
id DESC				= nil;
id DATA				= nil;
id STRING			= nil;



@interface AEVTBuilder : NSObject {} @end

@interface AEVTRecordBuilder : NSObject {} @end

@interface AEVTKeyBuilder : NSObject {} @end

@interface AEVTTypeBuilder : NSObject {} @end

@interface AEVTIntBuilder : NSObject {} @end

@interface AEVTEnumBuilder : NSObject {} @end

@interface AEVTDescNullBuilder : NSObject {} @end

@interface AEVTDataBuilder : NSObject {} @end

@interface AEVTStringBuilder : NSObject {} @end

@interface AEVTValue32 : NSObject {
	OSType type;
	OSType value;
}

+ valueWithType:(OSType)t value:(OSType)v;
- initWithType:(OSType)t value:(OSType)v;

- (OSType)type;
- (OSType)value;

@end


@implementation AEVTBuilder

+ (void)load
{
	if(!AEVT)
		AEVT = self;
}

+ (NSAppleEventDescriptor *)class:(OSType)eventClass id:(OSType)eventId target:(ProcessSerialNumber)psn, ...
{
	NSAppleEventDescriptor *targetDesc = [NSAppleEventDescriptor descriptorWithDescriptorType:'psn ' bytes:&psn length:sizeof(psn)];
	NSAppleEventDescriptor *descriptor = [NSAppleEventDescriptor
			appleEventWithEventClass:eventClass
							 eventID:eventId
					targetDescriptor:targetDesc
							returnID:kAutoGenerateReturnID
					   transactionID:kAnyTransactionID];
	
	va_list args;
	va_start(args, psn);
	
	id key;
	id value;
	for(;;)
	{
		key = va_arg(args, id);
		if(!key) break;
		value = va_arg(args, id);
		
		[descriptor setDescriptor:value forKeyword:[key unsignedIntValue]];
	}
	
	va_end(args);
	
	return descriptor;
}

@end

@implementation AEVTRecordBuilder

+ (void)load
{
	if(!RECORD)
		RECORD = self;
}

+ (id):(OSType)ostype, ...
{
	NSAppleEventDescriptor *descriptor = [NSAppleEventDescriptor recordDescriptor];
	
	va_list args;
	va_start(args, ostype);
	
	id key;
	id value;
	for(;;)
	{
		key = va_arg(args, id);
		if(!key) break;
		value = va_arg(args, id);
		
		[descriptor setDescriptor:value forKeyword:[key unsignedIntValue]];
	}
	
	va_end(args);
	
	AEDesc coercedDesc;
	OSStatus err = AECoerceDesc([descriptor aeDesc], ostype, &coercedDesc);
	if(err)
	{
		NSLog(@"Got error %d when calling AECoerceDesc");
		return nil;
	}
	
	NSAppleEventDescriptor *coercedDescriptor = [[NSAppleEventDescriptor alloc] initWithAEDescNoCopy:&coercedDesc];

	return [coercedDescriptor autorelease];
}

@end

@implementation AEVTKeyBuilder

+ (void)load
{
	if(!KEY)
		KEY = self;
}

+ (id):(OSType)ostype, ...
{
	return [NSNumber numberWithUnsignedInt:ostype];
}

@end

@implementation AEVTTypeBuilder

+ (void)load
{
	if(!TYPE)
		TYPE = self;
}

+ (id):(OSType)ostype, ...
{
	return [NSAppleEventDescriptor descriptorWithTypeCode:ostype];
}

@end

@implementation AEVTIntBuilder

+ (void)load
{
	if(!INT)
		INT = self;
}

+ (id):(OSType)ostype, ...
{
	return [NSAppleEventDescriptor descriptorWithInt32:ostype];
}

@end

@implementation AEVTEnumBuilder

+ (void)load
{
	if(!ENUM)
		ENUM = self;
}

+ (id):(OSType)ostype, ...
{
	return [NSAppleEventDescriptor descriptorWithEnumCode:ostype];
}

@end

@implementation AEVTDescNullBuilder

+ (void)load
{
	if(!DESC)
		DESC = self;
}

+ (id)null
{
	return [NSAppleEventDescriptor nullDescriptor];
}

@end

@implementation AEVTDataBuilder

+ (void)load
{
	if(!DATA)
		DATA = self;
}

+ (id):(OSType)ostype, ...
{
	va_list args;
	va_start(args, ostype);
	
	id data = va_arg(args, id);
	
	NSAppleEventDescriptor *descriptor = [NSAppleEventDescriptor descriptorWithDescriptorType:ostype data:data];
	
	va_end(args);
	
	return descriptor;
}

@end

@implementation AEVTStringBuilder

+ (void)load
{
	if(!STRING)
		STRING = self;
}

+ (id):(NSString *)string
{
	return [NSAppleEventDescriptor descriptorWithString:string];
}

@end


@implementation NSAppleEventDescriptor (AEVTConvenienceMethods)

- (NSAppleEventDescriptor *)sendWithImmediateReply
{
	AppleEvent reply;
	OSStatus err = AESendMessage([self aeDesc], &reply, kAEWaitReply, kAEDefaultTimeout);
	NSAppleEventDescriptor *replyDescriptor = nil;
	
	if(err == noErr)
	{
		replyDescriptor = [[[NSAppleEventDescriptor alloc] initWithAEDescNoCopy:&reply] autorelease];
	}
	
	return replyDescriptor;
}

@end
