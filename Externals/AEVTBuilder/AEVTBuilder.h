//
//  AEVTBuilder.h
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

#import <Cocoa/Cocoa.h>
#import <CoreServices/CoreServices.h>


@protocol AEVTBuilding

- (NSAppleEventDescriptor *)class:(OSType)eventClass id:(OSType)eventId target:(ProcessSerialNumber)psn, ...;

@end

@protocol AEDescBuilding

- (id):(OSType)ostype, ...;

@end

@protocol AENullBuilding

- (id)null;

@end

@protocol AEStringBuilding

- (id):(NSString *)str;

@end


extern id <AEVTBuilding> AEVT;

extern id <AEDescBuilding> RECORD;
extern OSType ENDRECORD;

extern id <AEDescBuilding> KEY;
extern id <AEDescBuilding> TYPE;
extern id <AEDescBuilding> INT;
extern id <AEDescBuilding> ENUM;
extern id <AENullBuilding> DESC;
extern id <AEDescBuilding> DATA;
extern id <AEStringBuilding> STRING;


@interface NSAppleEventDescriptor (AEVTConvenienceMethods)

- (NSAppleEventDescriptor *)sendWithImmediateReply;

@end
